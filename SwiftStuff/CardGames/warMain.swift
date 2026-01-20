class Card {
    var suit: String = ""
    var rank: Int = 0

    init(suit: String, rank: Int) {
        self.suit = suit
        self.rank = rank
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
    }


    var cards: [Card] = [Card]()

    func createDeck(numDecks numberOfDecks: Int = 2) {
        cards.removeAll()

        for _ in 0..<numberOfDecks {
            for suit in SUITS {
                for value in VALUE_MAP.allCases {
                    let card = Card(
                        suit: suit,
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

    func deal(numberOfCards numCards: Int = 1, deckToUse deck: Deck) -> [Card] {
        for _ in 1...numCards{
            //removes the card at the first index and appends it to the hand
            let card = deck.removeCard(index: deck.cards.count - 1)
            hand.append(card)
        }
        return hand
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

}

func runGame(players: [Player]) {
    print("Running game")
    while checkStatus(players: players) == 2 {
        let battleResult = battle(players: players)
        if battleResult != 2 {
            print("Player  \(battleResult + 1) won")
            break
        }
           
    
    }
    if checkStatus(players: players) == 0 {
        print("Player 1 wins.")
    } else if checkStatus(players: players) == 1{
        print("Player 2 wins.")
    } else {
        print("What the helly")
    }
}

func checkStatus(players: [Player]) -> Int {
    if players[0].hand.count <= 0{
        return 1
    } else if players[1].hand.count <= 0 {
        return 0
    } else {
        return 2
    }
}

func checkWarReady(players: [Player], numWars: Int) -> Int {
    if players[0].hand.count <= numWars*3{
        return 1
    } else if players[1].hand.count <= numWars*3 {
        return 0
    } else{
        return 2
    }

}

func battle(players: [Player]) -> Int {
    print("Battling")

    let firstPlayerRank: Int = players[0].hand[0].rank
    let secondPlayerRank: Int = players[1].hand[0].rank
    if firstPlayerRank > secondPlayerRank {
        print("Player One wins the battle.")
        players[0].hand.append(players[1].hand.remove(at: 0))
        players[0].hand.append(players[0].hand.remove(at: 0))
    }
    else if secondPlayerRank > firstPlayerRank {
        print("Player Two wins the battle.")
        players[1].hand.append(players[0].hand.remove(at: 0))
        players[1].hand.append(players[1].hand.remove(at: 0))
    }
    else if firstPlayerRank == secondPlayerRank {
        print("War!")
        var numWars = 1
        var warStatus = checkWarReady(players: players, numWars: numWars)
        guard warStatus == 2 else {
            return warStatus
        }

        var warResult = war(players: players, numWars: numWars)
        while warResult == (false, 0) {
             numWars += 1
             warStatus = checkWarReady(players: players, numWars: numWars)
            guard warStatus == 2 else {
            return warStatus
            }
             warResult = war(players: players, numWars: numWars)
        }
        let rounds = warResult.1; let winner = warResult.0
        guard rounds > 0 else {
            return 2
        }
        if winner {
            for index: Int in (0...rounds).reversed() {
                    print("Removing card \(index)")
                    players[0].hand.append(players[1].hand.remove(at: index))
                    print("Removed. ")
            }
            players[0].hand.append(players[0].hand.remove(at: 0))
        } else {
            for index: Int in (0...rounds).reversed() {
                print("Removing card \(index)")
                players[1].hand.append(players[0].hand.remove(at: index))
                print("Removed")

                
            }
            players[1].hand.append(players[1].hand.remove(at: 0)) 
        }
    }
    return 2
    
}

func war(players: [Player], numWars: Int = 1) -> (Bool, Int) {
    //each player lays three cards face down, and one face up.
    print(numWars)
    let firstPlayerRank: Int = players[0].hand[numWars*3].rank
    let secondPlayerRank: Int = players[1].hand[numWars*3].rank
    print("\(firstPlayerRank) vs \(secondPlayerRank)")
    if firstPlayerRank > secondPlayerRank {
        print("Player One wins the war.")
        print(numWars)
        return (true, numWars*3)
    }
    else if secondPlayerRank > firstPlayerRank {
        print("Player Two wins the war.")
        return (false, numWars*3)
    }
    else if firstPlayerRank == secondPlayerRank {
        print("Loop!")
        return (false, 0)
    }
    return (false, 0)
}

func main() {
    let manager: Manager = Manager()
    let deck: Deck = Deck()
    let player1: Player = Player()
    let player2: Player = Player()
    deck.createDeck(numDecks: 1)
    deck.shuffleCards()
    let players: [Player] = [player1, player2]
    manager.circularDeal(players: players, deck: deck, numberOfCards: 26)

    runGame(players: players)

}
main()