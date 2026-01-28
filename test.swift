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
        .ace: 1,
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
        .king: 13
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

enum MELD_TYPES: String {
    case set = "set"
    case run = "run"
}

class PossibleBestHand {
    var melds: [Meld] = []
    var size: Int = 0
    var score: Int = 0

    init (melds: [Meld], size: Int, score: Int) {
        self.melds = melds
        self.size = size
        self.score = score
    }
}

func calculateHandScore(cards: [Card]) -> Int {
    var score = 0
    for card in cards {
        score += card.value
    }
    return score
}

func findBestHand(playerHand cards: [Card]) {

    
}

func findRuns(cards: [Card]) -> [Meld] {
    let suitGroups: [String: [Card]]  = Dictionary(grouping: cards, by: { $0.suit })
    var runs: [Meld] = []
    //for each suit
    for (_, suitGroup) in suitGroups {
        let sortedGroup = suitGroup.sorted(by: { $0.rank < $1.rank } )
        var cardsInSequence: [Card] = []
        var currentCard: Card
        //saves the first card for comparison
        currentCard = sortedGroup[0]
        //appends the first card to cardsInSequence to ensure it is saved if it is in sequence.
        cardsInSequence.append(currentCard)
        //for each card in the suit
        for card in sortedGroup {
            //skips the first card, as that is the card used for comparison
            if card.face == sortedGroup[0].face {
                continue
            }
            //Checks if the card is one greater than
            if card.rank == currentCard.rank + 1 {
                cardsInSequence.append(card)
            } else {
                cardsInSequence = [card]
            }
            print("\n")
            if cardsInSequence.count >= 3 {
                runs.append(createRun(cards: cardsInSequence))
            }
            currentCard = card
        }
    }

    if runs.isEmpty {
        return runs
    }
    var tempRuns: [Meld] = runs
    while !tempRuns.isEmpty {
        var meldHolder: [Meld] = []
        for meld in tempRuns {
            if meld.size > 3 {
                meldHolder.append(createRun(cards: Array(meld.cards.dropFirst())))
                runs.append(createRun(cards: Array(meld.cards.dropFirst())))
            }
        }
        tempRuns = meldHolder
    }

    return runs
}

func createRun(cards: [Card]) -> Meld {
    return Meld(type: MELD_TYPES.run.rawValue, size: cards.count, score: calculateHandScore(cards: cards), cards: cards)
}

func findSets(cards: [Card]) -> [Meld] {
    let faceGroups: [String: [Card]]  = Dictionary(grouping: cards, by: { $0.face })
    var sets: [Meld] = []
    for (_, group) in faceGroups where group.count >= 3 {
        //FIX: This code does not handle groups of 4 cards correctly. Should find and store each combination of three, and store the combination of four.
        sets.append(Meld(
            type: MELD_TYPES.set.rawValue,
            size: group.count,
            score: calculateHandScore(cards: group),
            cards: group
            ))
    }
    return sets
} 

// func compareSetsAndRuns (sets: [Meld], runs: [Meld]) -> [Meld] {

// }


func main() {
    //Challenging hand to find the optimal melds for
    var hand: [Card] = [
        Card(suit: "Spades", face: "8", value: 8, rank: 8), 
        Card(suit: "Spades", face: "9", value: 9, rank: 9), 
        Card(suit: "Spades", face: "10", value: 10, rank: 10), 
        Card(suit: "Spades", face: "Jack", value: 11, rank: 11), 
        Card(suit: "Spades", face: "Queen", value: 12, rank: 12),
        Card(suit: "Hearts", face: "Queen", value: 12, rank: 12),
        Card(suit: "Diamonds", face: "Queen", value: 12, rank: 12),
        Card(suit: "Spades", face: "King", value: 13, rank: 13),
        Card(suit: "Hearts", face: "King", value: 13, rank: 13),
        Card(suit: "Diamonds", face: "King", value: 13, rank: 13)] //REMOVE AFTER TESTING
    hand.shuffle()
    print(calculateHandScore(cards: hand))
    let runs = findRuns(cards: hand)
    let sets = findSets(cards: hand)
    for run in runs {
        for card in run.cards {
            print(card.getInfo())
        }
        print("\n")
    }
    for set in sets {
        for card in set.cards {
            print(card.getInfo())
        }
        print("\n")
    }

}

main()



