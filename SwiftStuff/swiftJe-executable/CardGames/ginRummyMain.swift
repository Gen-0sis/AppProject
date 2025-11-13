//gin rummy
class Card {
    var suit: String = ""
    var face: String = ""
    var value: Int = 0
    var rank: Int = 0

    init(suit: String, face: String, value:Int, rank: Int) {
        self.suit = suit
        self.face = face
        self.value = value
        self.rank = rank
    }

    func getInfo() -> String {
        return "\(face) of \(suit)"
    }
}

class Deck {
    let SUITS: [String] = ["Spades", "Diamonds", "Clubs", "Hearts"]

    enum VALUE_MAP: Int {
        case ace = 1
        case king, queen, jack, ten = 10
        case nine = 9
        case eight = 8
        case seven = 7
        case six = 6
        case five = 5
        case four = 4
        case three = 3
        case two = 2
    }

    func valueString(_ value: Deck.VALUE_MAP) -> String {
        switch value {
            case .ace: return "Ace"
            case .king: return "King"
            case .queen: return "Queen"
            case .jack: return "Jack"
            case .ten: return "10"
            case .nine: return "9"
            case .eight: return "8"
            case .seven: return "7"
            case .six: return "6"
            case .five: return "5"
            case .four: return "4"
            case .three: return "3"
            case .two: return "2"
        }
    }

    let RANKS: [Deck.VALUE_MAP: Int] = [
        .two: 2,
        .three: 3,
        .four: 4,
        .five: 5,
        .six: 6,
        .seven: 7,
        .eight: 8,
        .nine: 9,
        .ten: 10,
        .jack: 11,
        .queen: 12,
        .king: 13,
        .ace: 14
    ]

    let VALUES: [VALUE_MAP] = [.two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king, .ace]

    var cards: [Card] = [Card]()

    func createDeck(numDecks numberOfDecks: Int = 2){
        //Iterates through the number of 52 card decks to create, by default 2
        for _ in 1...numberOfDecks{
            //Iterates through each suit, and for each suit each face.
            for suit in SUITS {
                for value in VALUES {
                    //Creates cards and adds them to the cards array
                    cards.append(Card(
                        suit: suit, 
                        face: valueString(value), //retrieves the name of the enum case as the face.
                        value: value.rawValue,
                        rank: RANKS[value] ?? 0
                        ))
                }

            }
        }
    }
    func shuffleCards() {
        cards.shuffle()
    }

    func removeCard(index indexToRemove: Int) -> Card {
        let tempCard = cards[indexToRemove]
        cards.remove(at: indexToRemove)
        return tempCard
    }

    func addCard(card cardToAdd: Card) {
        cards.append(cardToAdd)
    }

    func combineDecks(drawPile deckToAdd: Deck) {
        cards.append(contentsOf: deckToAdd.cards)
        deckToAdd.cards.removeAll()
    }
}

class Player {
    var hand: [Card] = []

    func deal(numberOfCards numCards: Int = 1, indexToDeal cardIndex: Int = 0, deck: Deck) -> [Card] {
        for _ in 1...numCards {
            hand.append(deck.removeCard(index: cardIndex))
        }
        return hand
    }

    func discard(indexToDiscard cardIndex: Int, deck: Deck) {
        let tempCard = hand[cardIndex]
        hand.remove(at: cardIndex)
        deck.addCard(card: tempCard)
    }
}

class Manager {
    func circularDeal(players: [Player], deck: Deck, numberOfCards numCards: Int = 1, indexToDeal cardIndex: Int = 0) {
        for _ in 1...numCards {
            for player in players {
                player.deal(numberOfCards: 1, indexToDeal: cardIndex, deck: deck)
            }
        }
    }
}

class Meld {
    //'set' or 'run'
    var type: String = ""
    var size: Int = 0
    var score: Int = 0
    var cards: [Card] = []

    init(type: String, size: Int, score:Int, cards: [Card]) {
        self.type = type
        self.size = size
        self.score = score
        self.cards = cards
    }

}

func findScoringHands(playerHand cards: [Card]) {

    enum MELD_TYPES: String {
        case run = "Run"
        case set = "Set"
    }

    let VALUE_MAP: [String : Int] = [ "Ace": 1, "King": 10, "Queen": 10, "Jack": 10, "10": 10, "9": 9, "8": 8, "7": 7, "6": 6, "5": 5, "4": 4, "3": 3, "2": 2 ]


    func calculateHandScore(cards: [Card]) -> Int {
        var score = 0
        for card in cards {
            score += VALUE_MAP[card.face] ?? 0
        }
        return score
    }

    //will store possible scoring hands found in the player's hand, with the hand type as the key and the score as the value. The highest scoring hand will be returned.
    var possibleMelds: [Meld] = []
    var confirmedMelds: [Meld] = []
    //must  find cards of the same rank or in sequence of the same suit
    //then compare the found hands to determine the best scoring hand
    //then return that hand


    //suitGroups will hold the cards grouped by suit to find sequences (e.g. 4 of Hearts, 5 of Hearts, 6 of Hearts, etc)
    let suitGroups: [String: [Card]]  = Dictionary(grouping: cards, by: { $0.suit })

    //iterates thru faceCounts to find sets of 3 or more of the same face
    let faceGroups = Dictionary(grouping: cards, by: { $0.face })
    for (_, group) in faceGroups where group.count >= 3 {
        possibleMelds.append(Meld(
            type: MELD_TYPES.set.rawValue,
            size: group.count,
            score: calculateHandScore(cards: group),
            cards: group
            ))
    }

    //iterates thru suitGroups to find sequences of 3 or more in the same suit
    //Note: Overlapping sequences are not allowed; each card can only be used in one meld.
    //If multiple melds have the same score, the first found meld is selected as the best hand.
    for (_, suitCards) in suitGroups {
        //sorts the cards in the suit by rank
        let sortedSuitCards: [Card] = suitCards.sorted { $0.rank < $1.rank }
        //sequenceCards will hold the cards in viable sequences
        var sequenceCards: [Card] = []
        //currentCard will hold the current card being compared
        if !sortedSuitCards.isEmpty {
            var currentCard: Card = sortedSuitCards[0]
            sequenceCards.append(sortedSuitCards[0]) 
            for i in 1..<sortedSuitCards.count {
            if sortedSuitCards[i].rank == currentCard.rank + 1 {
                sequenceCards.append(sortedSuitCards[i])
                currentCard = sortedSuitCards[i]
            } else {
                //if the sequence is broken, check if the sequenceCards array has 3 or more cards
                if sequenceCards.count >= 3 {
                    possibleMelds.append(Meld(
                        type: MELD_TYPES.run.rawValue,
                        size: sequenceCards.count,
                        score: calculateHandScore(cards: sequenceCards),
                        cards: sequenceCards
                        ))
                }
                //reset sequenceCards and currentCard
                sequenceCards = [sortedSuitCards[i]]
                currentCard = sortedSuitCards[i]
            }
        }
    }
    //after the loop, check if there is a remaining sequence to add
    if sequenceCards.count >= 3 {
        possibleMelds.append(Meld(
            type: MELD_TYPES.run.rawValue,
            size: sequenceCards.count,
            score: calculateHandScore(cards: sequenceCards),
            cards: sequenceCards
            ))
    }
}
    
     


    // if possibleHands.isEmpty {
    //     print("No scoring hands found.")
    // } else {
    //     //sort possibleHands by score in descending order
    //     let sortedHands = possibleHands.sorted { $0.1 > $1.1 }
    //     let bestHand = sortedHands[0]
    //     print("Best scoring hand found with score \(bestHand.1):")
    //     for card in bestHand.0 {
    //         print(card.getInfo())
    //     }
    // }
    //must determine if possible hands are mutually exclusive
    var meldsToCompare: [Meld] = []
    //Sorts meld by type. Reverse order because run is before set by default, and having sets first is easiest for comparison.
    for (index,meld) in possibleMelds.sorted(by: { $0.type > $1.type }).enumerated() {
        meldsToCompare.append(meld)
        possibleMelds.remove(at: index)
        if meld.type != MELD_TYPES.set.rawValue {
            break
        }
    }

    for meldToCompare in meldsToCompare {
        for meld in possibleMelds{
            // Check if any card in the current meld shares the same face value as the first card in meldToCompare (to identify overlapping cards between melds)
            let sameFaceCard = meld.cards.filter { $0.face == meldToCompare.cards[0].face }
            if !sameFaceCard.isEmpty {
                for cardToCompare in meldToCompare.cards {
                    // Reference the first card of sameFaceCard b/c sameFaceCard is taken from a set and as such will not have more than one card of the same face.
                    if cardToCompare.suit == sameFaceCard[0].suit {
                        
                    }
                }
            }
        }
    }
}
