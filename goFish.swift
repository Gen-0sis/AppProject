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

func runGame(players: [Player], deck: Deck ) {
    print("Choose a card to ask for")
    let selectedCard: Int = takeInput() ?? 0
    print("Choose a player to ask")
    let selectedPlayer: Int = takeInput() ?? 1
    runTurn(players: players, deck: deck, playerActor: true, cardNum: selectedCard, playerNum: selectedPlayer)
    
    //AI turns
    let lastFourCards = [Card]
    if lastFourCards.size > 4 {
        lastFourCards.popLast()
    }
    for playerNum in 1...<players.count {
        
        print("player \(playerNum) asks player \()")
    }
}

func takeInput() -> Int {
    RETURN BUTTONRESPONSE()
}

func runTurn(players: [Player], deck:Deck, playerActor: Bool = false, cardNum: Int = 0, playerNum: Int = 0) {
    //Takes the input, maps the values of the selected players cards to see if they contain the target.
    if players[selectedPlayer].cards.map{ $0.rank }.contains(selectedCard) {
        let indeces: [Int] = []
        //Takes the indeces of every instance of the targeted card.
        for (index,card) in players[selectedPlayer].cards.enumerated() {
            if card.value = selectedCard {
                indeces.append(index)
            }
        }
        //reverses the indeces, then removes the cards at those indeces from the selected player's hand and adds them to the current player's hand.
        for index in indeces.reversed() {
            let card = players[selectedPlayer].removeCard(index)
            players[0].append(card)
        }

    }
    else {
        print("Choosing random card")
        //use for AI, have player choose a 
        players[0].append(deck.removeCard(Int.random(in: 0...(deck.size()-1))))'
        print
    }
}


func main() {
    let manager: Manager = Manager()
    let deck: Deck = Deck()
    var players: [Player] = []

    //player creation
    print("Enter num players (4 max, default 2):")
    let playerInput: String? = readLine()
    let numPlayers = Int(playerInput ?? "") ?? 2
    if numPlayers > 4 { numPlayers = 4 }
    print("Starting with \(numPlayers) players")
    let numCards: Int = 9 - numPlayers
    print("Each player getting \(numCards) cards")
    
    //deck creation
    deck.createDeck(numDecks: 1)
    deck.shuffleCards()

    //initial deal
    manager.circularDeal(players: players, deck: deck, numberOfCards: numCards)

    runGame(players: players, deck: deck)
}
main()