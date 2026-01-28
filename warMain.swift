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
            case .ace: return 14
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

enum GameState: String { case ongoing = "ongoing", player0Wins = "player0Wins", player1Wins = "player1Wins", tie = "tie", warLoop = "warLoop", endOfFunctionError = "endOfFunctionError", warRoundsError = "warRoundsError"}

func runGame(players: [Player]) {
    print("Running game")
    var battleResult: GameState = .ongoing
    while checkStatus(players: players) == GameState.ongoing {
         battleResult = battle(players: players)
        if battleResult != .ongoing {
            print("No longer ongoing: \(battleResult.rawValue)")
            break
        }
           
    
    }
    print(players[0].hand.count)
    print(players[1].hand.count)
    if battleResult == GameState.player0Wins {
        print("Player 1 wins.")
        print(players[0].hand.count)
    } else if battleResult == GameState.player1Wins{
        print("Player 2 wins.")
        print(players[1].hand.count)
    } else {
        print("Error: \(battleResult.rawValue)")
    }
}

func checkStatus(players: [Player]) -> GameState {
    if players[0].hand.count <= 0{
        return .player1Wins
    } else if players[1].hand.count <= 0 {
        return .player0Wins
    } else {
        return .ongoing
    }
}

func checkWarReady(players: [Player], numWars: Int) -> GameState {
    if players[0].hand.count < (numWars*4) + 1{
        return .player1Wins
    } else if players[1].hand.count < (numWars*4) + 1 {
        return .player0Wins
    } else{
        return .ongoing
    }

}

func moveCards(winnerIndex: Int, players: [Player]) {
    let cards = [players[0].hand.remove(at:0), players[1].hand.remove(at:0)]
    players[winnerIndex].hand.append(contentsOf: cards)
}

func battle(players: [Player]) -> GameState {
    print("Battling")

    let firstPlayerRank: Int = players[0].hand[0].rank
    let secondPlayerRank: Int = players[1].hand[0].rank
    print("\(firstPlayerRank) vs \(secondPlayerRank)")
    
    if firstPlayerRank > secondPlayerRank {
        print("Player One wins the battle.")
        moveCards(winnerIndex: 0, players: players)
        return checkStatus(players: players)
    }
    else if secondPlayerRank > firstPlayerRank {
        print("Player Two wins the battle.")
        moveCards(winnerIndex: 1, players: players)
        return checkStatus(players: players)
    }
    else if firstPlayerRank == secondPlayerRank {
        print("War!")
        var numWars = 1
        var warStatus = checkWarReady(players: players, numWars: numWars)
        guard warStatus == GameState.ongoing else {
            return warStatus
        }

        var warResult = war(players: players, numWars: numWars)

        //war loop
        while warResult.0 == GameState.warLoop {
             numWars += 1
             warStatus = checkWarReady(players: players, numWars: numWars)
            guard warStatus == GameState.ongoing else {
            return warStatus
            }
             warResult = war(players: players, numWars: numWars)
        }
        //if there were 0 rounds, return an error.
        let rounds = warResult.1; let winner = warResult.0
        guard rounds > 0 else {
            return .warRoundsError
        }

        let totalSpoils = Array(players[0].hand[0..<rounds*4]) + Array(players[1].hand[0..<rounds*4])

        if winner == GameState.player0Wins {
            //Must append the total spoils and remove the half contributed by both players
            players[0].hand.append(contentsOf: totalSpoils)
            players[1].hand.removeSubrange(0..<rounds*4)
            players[0].hand.removeSubrange(0..<rounds*4)
        } else {
            players[1].hand.append(contentsOf: totalSpoils)
            players[0].hand.removeSubrange(0..<rounds*4)
            players[1].hand.removeSubrange(0..<rounds*4)
        }
        return checkStatus(players: players)

    }
    return .endOfFunctionError
    
}

func war(players: [Player], numWars: Int = 1) -> (GameState, Int) {
    //each player lays three cards face down, and one face up.
    let numCards = numWars*4
    let firstPlayerRank: Int = players[0].hand[numCards].rank
    let secondPlayerRank: Int = players[1].hand[numCards].rank
    print("\(firstPlayerRank) vs \(secondPlayerRank)")
    if firstPlayerRank > secondPlayerRank {
        print("Player One wins the war.")
        print(numWars)
        return (.player0Wins, numWars)
    }
    else if secondPlayerRank > firstPlayerRank {
        print("Player Two wins the war.")
        return (.player1Wins, numWars)
    }
    else if firstPlayerRank == secondPlayerRank {
        print("Loop!")
        return (.warLoop, numWars)
    }
    return (.warRoundsError, 0)
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