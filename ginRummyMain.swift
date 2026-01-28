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

    enum VALUE_MAP: CaseIterable {
        case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king

        var rank: Int {
            switch self {
            case .ace: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten: return 10
            case .jack: return 11
            case .queen: return 12
            case .king: return 13
            }
        }

        var value: Int {
            switch self {
            case .ace: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten, .jack, .queen, .king:
                return 10
            }
        }

        var displayName: String {
            switch self {
            case .ace: return "Ace"
            case .jack: return "Jack"
            case .queen: return "Queen"
            case .king: return "King"
            case .two: return "2"
            case .three: return "3"
            case .four: return "4"
            case .five: return "5"
            case .six: return "6"
            case .seven: return "7"
            case .eight: return "8"
            case .nine: return "9"
            case .ten: return "10"
            }
        }
    }

    let VALUES: [VALUE_MAP] = [.two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king, .ace]

    var cards: [Card] = [Card]()

    func createDeck(numDecks numberOfDecks: Int = 2) {
        cards.removeAll()

        for _ in 0..<numberOfDecks {
            for suit in SUITS {
                for value in VALUE_MAP.allCases {
                    let card = Card(
                        suit: suit,
                        face: value.displayName,
                        value: value.value,   // scoring value
                        rank: value.rank      // rank for runs
                    )
                    cards.append(card)
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
    var score: Int = 0
    var bestHand: [Meld] = []

    func deal(numberOfCards numCards: Int = 1, deckToUse deck: Deck) -> [Card] {
        for _ in 1...numCards{
            //removes the card at the first index and appends it to the hand
            let card = deck.removeCard(index: deck.cards.count - 1)
            hand.append(card)
        }
        return hand
    }

    func discard(indexToDiscard cardIndex: Int, deck: Deck) {
        let tempCard = hand[cardIndex]
        hand.remove(at: cardIndex)
        deck.addCard(card: tempCard)
    }

    func findDeadwood(hand: [Card], handFinder: HandFinder) -> Int{
        var tempFinder = handFinder
        var tempScore: Int = 0
        var bestHand: [Meld] = tempFinder.findBestHand(playerHand: hand)
        for card in hand {
            tempScore += card.value
        }
        for meld in bestHand {
            tempScore -= meld.score
        }
        return tempScore
    }
}   

class Manager {
    var scores: [Int] = [0,0]
    func circularDeal(players: [Player], deck: Deck, numberOfCards numCards: Int = 1) {
        for _ in 1...numCards {
            for player in players {
                player.deal(numberOfCards: 1, deckToUse: deck)
            }
        }
    }

    func knock(players: [Player], handFinder: HandFinder) {
        for (index,player) in players.enumerated() {
            scores[index] = player.findDeadwood(hand: player.hand, handFinder: handFinder)
        }
        //unfinished
    }

    func placeFaceUp(index: Int = 0, deck: Deck, faceUpDeck: Deck) {
        var optionalCard: Card? = deck.removeCard(index: index)
        if let card = optionalCard {
            faceUpDeck.cards.append(card)
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

struct HandFinder {

    var bestMelds: [Meld] = []
    var bestScore: Int = 0

    mutating func findBestHand(playerHand cards: [Card]) -> [Meld] {

        let runs = findRuns(cards: cards)
        let sets = findSets(cards: cards)
        let allMelds = sets + runs

        backtrack(melds: allMelds, index: 0, current: [], currentScore: 0)

        return bestMelds
    }

    mutating func backtrack(melds: [Meld], index: Int, current: [Meld], currentScore: Int, depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)Index \(index), Score \(currentScore)")
        // reached the end
        if index == melds.count {
            if currentScore > bestScore {
                bestScore = currentScore
                bestMelds = current
            }
            return
        }

        let meld = melds[index]

            // --- Branch 1: SKIP ---
        backtrack(
            melds: melds,
            index: index + 1,
            current: current,
            currentScore: currentScore
        )
        
        // --- Branch 2: INCLUDE (only if compatible) ---
        for m in current {
            if !isCompatible(m, meld) {
                return   // incompatible: cannot take this branch
            }
        }

        var newCurrent = current
        newCurrent.append(meld)

        backtrack(
            melds: melds,
            index: index + 1,
            current: newCurrent,
            currentScore: currentScore + meld.score
        )
    }
}


func findRuns(cards: [Card]) -> [Meld] {
    let suitGroups: [String: [Card]]  = Dictionary(grouping: cards, by: { $0.suit })
    var runs: [Meld] = []
    //for each suit
    for (_, suitGroup) in suitGroups {
        var sortedGroup = suitGroup.sorted(by: { $0.rank < $1.rank } )
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
        var newTemp: [Meld] = []
        for meld in tempRuns {
            if meld.cards.count < 3 {
                continue
            }
            let dropped = Array(meld.cards.dropFirst())
            if dropped.count >= 3 && isConsecutive(dropped) {   
                let newRun = createRun(cards: dropped)
                runs.append(newRun)
                newTemp.append(newRun)
            }
        }
        tempRuns = newTemp
    }
    return runs
}

func isConsecutive(_ cards: [Card]) -> Bool {
    guard cards.count >= 2 else { return true }
    for i in 1..<cards.count {
        if cards[i].rank != cards[i-1].rank + 1 { return false }
    }
    return true
}

func createRun(cards: [Card]) -> Meld {
    return Meld(type: MELD_TYPES.run.rawValue, size: cards.count, score: calculateHandScore(cards: cards), cards: cards)
}

func createSet(cards: [Card]) -> Meld {
    return Meld(type: MELD_TYPES.set.rawValue, size: cards.count, score: calculateHandScore(cards: cards), cards: cards)
}

func findSets(cards: [Card]) -> [Meld] {
    let comboPaths: [[Int]] = [[0,1,2], [0,1,3], [0,2,3], [1,2,3]]
    let faceGroups: [String: [Card]]  = Dictionary(grouping: cards, by: { $0.face })
    var sets: [Meld] = []
    for (_, group) in faceGroups where group.count == 4 {
        sets.append(createSet(cards: group))
        for numArray in comboPaths {
            var tempSet: [Card] = []
            for num in numArray {
                tempSet.append(group[num])
            }
            sets.append(createSet(cards: tempSet))
        }
    }
    for (_, group) in faceGroups where group.count == 3 {
        sets.append(createSet(cards: group))
    }
    return sets
}

func isCompatible(_ firstMeld: Meld, _ secondMeld: Meld) -> Bool {
    let firstMeldCards = firstMeld.cards.sorted(by: {$0.rank > $1.rank}) 
    let secondMeldCards = secondMeld.cards.sorted(by: {$0.rank > $1.rank})
    //if both are runs of different suits, return true
    if firstMeld.type == "run" && secondMeld.type == "run" {
        if firstMeld.cards[0].suit != secondMeld.cards[0].suit {
            return true
        } else {
            //if the two overlap in rank, return false
            let firstRange = firstMeldCards.last!.rank ... firstMeldCards.first!.rank
            let secondRange = secondMeldCards.last!.rank ... secondMeldCards.first!.rank

            if firstRange.overlaps(secondRange) {
                print("Rank overlap incompatibility")
                return false
            }
            return true
        }
    }
    if firstMeld.type == "set" && secondMeld.type == "set" {
        if firstMeld.cards[0].face == secondMeld.cards[0].face {
            print("\(firstMeld.cards[0].getInfo) incompatible with \(secondMeld.cards[0].getInfo)")
            return false
        }   
    }
    for card in firstMeld.cards {
        for card2 in secondMeld.cards {
            if card.face == card2.face {
                if card.suit == card2.suit {
                    print(card.getInfo(), terminator: "")
                    print(" Incompatible with ")
                    print(card2.getInfo())
                    return false
                }
            }
        }
    }
    return true
}

func passingPhase(players: [Player], deck: Deck, faceUpCards visible: Deck, roundNumber round: Int = 1)  {
    for player in players {
        let input = input() //temporary
        if input == "Pass" {
            continue
        }
    }
    return

}

func playingPhase(_ player: Player, _ deck: Deck, _ visible: Deck) {
    for player in players {
        
    }
    //prompt player to pick up either top card or face up card
    //use handFinder here to display the best combo possible (optional)
    //once chosen, prompt to knock or discard
    //if knock
        //decideRoundWinner
    //else if discard
        //player.score = player.findDeadwood(hand: hand, handFinder: handFinder)
        //playingPhase(other player)
}

func decideRoundWinner(players: [Player]) {
    //unfinished, Jerry moment
}

func main() {

    //Game Loop
    let manager: Manager = Manager()
    let deck: Deck = Deck()
    let faceUpCards: Deck = Deck()
    let player1: Player = Player()
    let player2: Player = Player()
    let players: [Player] = [player1, player2]
    var handFinder = HandFinder()
    deck.createDeck(numDecks: 1)
    deck.shuffleCards()
    //the deal
    manager.circularDeal(players: players, deck: deck, numberOfCards: 10)
    manager.placeFaceUp(index: 0, deck: deck, faceUpDeck: faceUpCards)
    //pass phase

    players[0].findDeadwood(hand: players[0].hand, handFinder: handFinder)
    // passingPhase(players: players, deck: deck, faceUpCards: faceUpCards)

    //turn loop
        //continues until knock
    //while not knock
        //for player in players
            //playingPhase(player)


}

main()