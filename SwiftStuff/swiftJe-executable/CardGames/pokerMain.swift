//Poker game main file
//TODO
// Understand poker scoring
//Chip logic (values -> Chip type)


class Card {
    var suit: String = ""
    var face: String = ""
    var value: Int = 0

    init(suit: String, face: String, value:Int) {
        self.suit = suit
        self.face = face
        self.value = value
    }

    func getInfo() -> String {
        return "\(face) of \(suit)"
    }
}

class Deck {
    let SUITS: [String] = ["Spades", "Diamonds", "Clubs", "Hearts"]
    let FACES: [String] = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
    let VALUE_MAP: [String: Int] = ["Ace": 14, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,"Jack": 11, "Queen": 12, "King": 13]
    //this is code meant for wide application, .value will be mostly unused because poker relies on card combinations to score. 

    var cards: [Card] = [Card]()

    func createDeck(numDecks numberOfDecks: Int = 2){
        //Iterates through the number of 52 card decks to create, by default 2
        for _ in 1...numberOfDecks{
            //Iterates through each suit, and for each suit each face.
            for suit in SUITS {
                for face in FACES {
                    //Creates cards and adds them to the cards array
                    cards.append(Card(suit: suit, face: face, value: VALUE_MAP[face]!))
                }

            }
        }
    }

    func shuffleCards() -> Void{
        cards.shuffle()
    }

    func removeCard(index indexToRemove: Int) -> Card {
        //removes a card from the deck using its index in the deck and returns its value
        let tempcard: Card = cards[indexToRemove]
        cards.remove(at: indexToRemove)
        return tempcard
        //use for deal and hit
    }

    func addCard(card cardToAdd: Card) -> Void {
        //adds a card to the deck
        cards.append(cardToAdd)
    }

    func combineDecks(drawPile deckToAdd: Deck) -> Void{
        //combines two decks by adding all cards from the second deck to the first deck and emptying the second deck
        //for use adding the draw pile to the main deck at the end of the game
        for card in deckToAdd.cards{
            addCard(card: card)
        }
        deckToAdd.cards.removeAll()
    }

}

enum PokerHand: String {
    case royalFlush = "Royal flush"
    case straightFlush = "Straight flush"
    // case fiveOfAKind = "Five of a kind"
    case fourOfAKind = "Four of a kind"
    case fullHouse = "Full house"
    case flush = "Flush"
    case straight = "Straight"
    case threeOfAKind = "Three of a kind"
    case twoPair = "Two pair"
    case onePair = "One pair"
    case highCard = "High card"
}

class Manager {
    let HAND_RANKS: [PokerHand: Int] = [.royalFlush : 1, .straightFlush : 2, .fourOfAKind: 3, .fullHouse: 4, .flush: 5, .straight: 6, .threeOfAKind: 7, .twoPair: 8, .onePair: 9, .highCard: 10]
    var pot: Int = 0

    func addToPot(amount amountToAdd: Int) {
        pot += amountToAdd
    }

    func declareWinner(players: [Player], winner winningPlayer: Player, index winningPlayerIndex: Int) {
        
        for (index,player) in players.enumerated() {
            player.money -= player.bet
            player.bet = 0
        }
        print("Player \(winningPlayerIndex) wins $\(pot)")
        winningPlayer.money += pot
    }

}

class Player {  
    //hand is an empty array of card objects
    var hand: [Card] = []
    //placeholder values for money and bet
    var money: Int = 1000
    var bet: Int = 0
    var handType: PokerHand = .highCard
    var tieBreakerCard: Card = Card(suit: "", face: "", value: 0)


    func deal(numCards numberOfCards: Int = 1, deck deckToUse: Deck) -> [Card] {
        //deals the number of cards to the player from the selected deck
        for _ in 1...numberOfCards{
            //removes the card at the first index and appends it to the hand
            let card = deckToUse.removeCard(index: 0)
            hand.append(card)
        }

        return hand
    }

    func placeBet(amount betAmount: Int) -> Bool{
        //places a bet by reducing the player's money by the bet amount and setting the bet variable
        //used for the first player to place a bet
        if betAmount <= money{
            money -= betAmount
            bet += betAmount
            print("$\(betAmount) bet placed.")
            return true
        } else {
            print("Insufficient funds to place that bet.")
            return false
        }
    }

    func call(previousBet previousBetAmount: Int) -> Void{
        //calls a bet by placing a bet equal to the previous bet amount
        let amountToPay = previousBetAmount - bet
        if amountToPay > 0 {
            placeBet(amount: amountToPay)
        } else {
            print("Already matched the current bet.")
        }
    }

    func fold(discardPile pile: Deck) -> Void{
        //folds the player's hand by adding all cards in their hand to the discard pile and emptying their hand
        for card in hand{
            pile.addCard(card: card)
        }
        hand.removeAll()
    }

    func raise(previousBet previousBetAmount: Int, raiseAmount amountToRaise: Int) -> Bool {
        let totalBet = previousBetAmount + amountToRaise
        //this checks if the player has enough money to cover the total bet (previous bet + raise amount)
        //not currently applicable as each player has equal money, but will be useful in future
        if totalBet <= money + bet {   
            let amountToPay = totalBet - bet  
            money -= amountToPay
            bet = totalBet
            print("$\(totalBet) bet placed.")  
            return true
        } else {
            print("Insufficient funds to place that bet.")
            return false
        }
    }
}



struct pokerHands {
    //This is called on any array of card objects.
    let cards: [Card]

    var isFlush: Bool {
        //isFlush checks if each card is the same suit.
        // if you can set firstSuit equal to the suit of the suit of the first card, continue. else return false.
        guard let firstSuit = cards.first?.suit else { return false }
        //returns true if each suit is equal
        return cards.allSatisfy { $0.suit == firstSuit }
    }

    var isStraight: Bool {
        //gets an array of the values of each card, sorts it, and stores it in sortedValues.
        let sortedValues = cards.map { $0.value }.sorted()
        //iterates through sortedValues by index
        for i in 0..<sortedValues.count - 1 {
            //checks if any of the values are non-consecutive
            if sortedValues[i] + 1 != sortedValues[i + 1] {
                return false
            }
        }
        return true
    }

    var faceCounts: [String: Int] {
        //creates a dictionary of faces, then makes it count the amount of each face. e.g. a hand with two kings would have King: 2
        Dictionary(grouping: cards, by: { $0.face }).mapValues { $0.count }
    }

    var valueCounts: [Int: Int] {
        //does the same as faceCounts, but for values.
        Dictionary(grouping: cards, by: { $0.value }).mapValues { $0.count }
    }

    var isRoyal: Bool {
        let royalFaces = Set(["10", "Jack", "Queen", "King", "Ace"])
        //returns a boolean, true if the array of faces matches the Set
        return Set(cards.map { $0.face }) == royalFaces
    }

}

func runBettingRound(players:[Player], deck mainDeck: Deck, pile discardPile: Deck,ante anteAmount: Int = 0, manager: Manager) -> Void {
    //runs a betting round for the given players, using the given deck and discard pile
    //anteAmount is the amount each player must bet at the start of the round, defaults to 0
    //does not handle betting rounds after the first, where players can check if no bet has been made
    var currentBet: Int = anteAmount
    //playerStatus array will contain a boolean for each player, true if they are still in the round, false if they have folded, and their bet amount
    var playerStatus: [(Bool, Int)] = [(Bool, Int)]()
    var betsNotEqual: Bool = true

    for player in players {
        playerStatus.append((true, 0))
        //resets each player's bet to 0 at the start of the round (ensures no carryover from previous rounds)
        player.bet = 0
        //resets each player's money to 1000 for testing purposes
        player.money = 1000
    }

    //Collects antes from each player if anteAmount is greater than 0
    if anteAmount > 0 {
        takeAnte(players: players, deck: mainDeck, pile: discardPile, ante: anteAmount, status: &playerStatus)
        currentBet = anteAmount
    }

    while betsNotEqual {
        takeBets(players:players, deck: mainDeck, pile: discardPile, statuses: &playerStatus, bet: &currentBet, manager: manager)

        //checks if all players have equal bets, if so ends the betting round
        //creates an array of the bets of all players still in the round (those with a true boolean in playerStatus)
        let activeBets = playerStatus.filter { $0.0 }.map { $0.1 }
        //unwraps the first bet in the array, and checks if all other bets are equal to it
        if let firstBet = activeBets.first {
            //sets betsNotEqual to true if any bet is not equal to the first bet
            betsNotEqual = !activeBets.allSatisfy { $0 == firstBet }
        } else {
            //if no active players remain, ends the betting round
            betsNotEqual = false
        }
    }

    for player in players {
        player.handType = checkPlayerHand(hand: player.hand)
        player.tieBreakerCard = getHighCard(player: player)
    }
    players = players.filter { $0.money > 0 && !$0.hand.isEmpty }

}

func takeBets(players:[Player], deck mainDeck: Deck, pile discardPile: Deck, statuses playerStatus: inout [(Bool, Int)], bet currentBet: inout Int, manager: Manager) -> [(Bool, Int)] {
    for (index,player) in players.enumerated() {

        if player.hand.isEmpty {
            //checks if player is folded, if so skips their turn
            continue
        }
        if currentBet > 0 {    
            print("The current bet is \(currentBet)")
        }
        if currentBet > player.money + player.bet {
            print("Player \(index + 1) does not have enough money to continue and must fold.")
            player.fold(discardPile: discardPile)
            continue
        }
        print("Player \(index + 1), what would you like to do (Bet, Call, Fold, or Raise)?")
        if let action = readLine()?.lowercased(){
            switch action {
                case "bet":
                    print("How much would you like to bet?")
                    //reads input from user and converts it to an integer (This catches invalid input)
                    if let betInput = readLine(), let betAmount = Int(betInput) {
                        //checks if the player was able to place the bet, if so updates the current bet (This catches bets that are too high)
                        if player.placeBet(amount: betAmount) {
                            currentBet = betAmount
                        }
                    } else {
                        print("Invalid bet amount")
                    }

                case "call":
                    if currentBet > 0 {
                        player.call(previousBet: currentBet)
                    } else {
                        //when the player calls, but there is no current bet, it is treated as a check
                        print("Checked.")
                    }

                case "fold":
                    print("Folded.")
                    player.fold(discardPile: discardPile)
                    //updates the player's status to folded
                    playerStatus[index].0 = false

                case "raise":
                    print("How much would you like to raise?")
                    if let raiseInput = readLine(), let raiseAmount = Int(raiseInput) {
                        if player.raise(previousBet: currentBet, raiseAmount: raiseAmount) {
                            currentBet += raiseAmount
                            break
                        }
                    } else {
                        print("Invalid bet amount")
                    }
                    
                default:
                    print("Invalid input")

            }
        }
        //If the player is still in the game, updates their bet amount.
        if playerStatus[index].0 {
            playerStatus[index].1 = currentBet
        }
    }
    checkStatus(players: players, manager: manager)
    return playerStatus
}
//returns the hand type
func checkPlayerHand(hand: [Card]) -> PokerHand {
    //counts becomes an array of the values of cards, sorted in descending order.
    let handEval = pokerHands(cards: hand)
    let faceCounts = handEval.faceCounts
    let counts = faceCounts.values.sorted(by: >)

    if handEval.isFlush && handEval.isStraight && handEval.isRoyal {
        //royal flush
        return .royalFlush
    } else if handEval.isFlush && handEval.isStraight {
        return .straightFlush
        //straight flush
    }
    //  else if counts == [5] {
    //     return .fiveOfAKind
    //     //Five of a kind
    // }
    else if counts == [4, 1] {
        return .fourOfAKind
        //four of a kind
    } else if counts == [3, 2] {
        return .fullHouse
        //full house
    } else if handEval.isFlush {
        return .flush
        //flush
    } else if handEval.isStraight {
        return .straight
        //straight
    } else if counts == [3, 1, 1] {
        return .threeOfAKind
        //three of a kind
    } else if counts == [2, 2, 1] {
        return .twoPair
        //two pair
    } else if counts == [2, 1, 1, 1] {
        return .onePair
        //one pair
    } else {
        return .highCard
        //high card
    }

}
//returns the card used as a tiebreaker
func getHighCard(player: Player) -> Card {
    let handEval = pokerHands(cards: player.hand)
    let faceCounts = handEval.faceCounts
    let handType = player.handType

    switch handType {
        case .royalFlush:
            //ace
            return player.hand.first { $0.face == "Ace" }!
        
        case .straightFlush, .highCard, .straight:
            //highest numerical value
            return player.hand.max(by: { $0.value < $1.value })!
        
        case .fourOfAKind:
            //any of the four
            return player.hand.first { faceCounts[$0.face] == 4 }!

        case .fullHouse, .threeOfAKind:
            return player.hand.first { faceCounts[$0.face] == 3 }!

        case .twoPair, .onePair:
        //max value card in pair
            return player.hand.filter { faceCounts[$0.face] == 2 }.max(by: { $0.value < $1.value })!
        default:
            return player.hand[0]

    }
}
//Takes ante bets from each player
func takeAnte(players:[Player], deck mainDeck: Deck, pile discardPile: Deck,ante anteAmount: Int, status: inout [(Bool, Int)]) -> Void {
    print("Current Ante: \(anteAmount). Collecting from each player...")
    for (index, player) in players.enumerated() {
        //folds players who cannot pay the ante
        if player.money < anteAmount{
            print("Player \(index) does not have enough money and has folded.")
            player.fold(discardPile: discardPile)
            status[index].0 = false

        }

        else {
            print("Player \(index) ponies up $\(anteAmount).")
            player.placeBet(amount: anteAmount)
            status[index].1 = anteAmount
        }
    }
}
//checks the status of the game. true if more than one player remains.
func checkStatus(players: [Player], manager: Manager) -> Bool {
    var activePlayers: Int = players.count
    for (index, player) in players.enumerated() {
        if activePlayers <= 1 {
            manager.declareWinner(players: players, winner: player, index: index)
            return false
        }
        if player.hand.isEmpty {
            activePlayers -= 1
        }

    }
    return true
}
//not yet implemented


func initializeGame(decks numDecks: Int = 1, players numPlayers: Int = 4) {
    //Creates an array of Player objects 
    let discardPile = Deck()
    let mainDeck = Deck()
    let manager = Manager()
    var players: [Player] = []
    

    for _ in 1...numPlayers {
        players.append(Player())
    }
    
    //numDecks is the number of 52 card decks to put into play.
    mainDeck.createDeck(numDecks: numDecks)
    mainDeck.shuffleCards()

    //deals 5 cards to each player
    for player in players {
        player.deal(numCards: 5, deck: mainDeck)
    }

    //not the final place to put this, just testing the betting round function
    runBettingRound(players: players, deck: mainDeck, pile: discardPile, manager: manager)
    
}