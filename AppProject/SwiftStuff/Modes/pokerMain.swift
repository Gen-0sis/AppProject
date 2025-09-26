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

    
    func createDeck(numDecks numberOfDecks: Int = 2) -> [Card] {
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
        return cards
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


class Player {
    //hand is an empty array of card objects
    var hand: [Card] = []
    //placeholder values for money and bet
    var money: Int = 1000
    var bet: Int = 0

    var suits: [String] = []
    var faces: [String] = []
    var values: [Int] = []


    func deal(numCards numberOfCards: Int = 1, deck deckToUse: Deck) -> [Card] {
        //deals the number of cards to the player from the selected deck
        for _ in 1...numberOfCards{
            //removes the card at the first index and appends it to the hand
            let card = deckToUse.removeCard(index: 0)
            hand.append(card)
            suits.append(card.suit)
            faces.append(card.face)
            values.append(card.value)
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

 
func runBettingRound(players:[Player], deck mainDeck: Deck, pile discardPile: Deck,ante anteAmount: Int = 0) -> Void {
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
        takeBets(players:players, deck: mainDeck, pile: discardPile, status: &playerStatus, bet: &currentBet)

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
}

func takeBets(players:[Player], deck mainDeck: Deck, pile discardPile: Deck, statuses playerStatus: inout [(Bool, Int)], bet currentBet: inout Int) -> [(Bool, Int)] {
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
    checkStatus(players: players)
    return playerStatus
}

//will return hand type, highest card
func runScoringRound(player: Player, statuses playerStatus: [(Bool, Int)], bet currentBet: Int) -> (String, String) {

    
    let face = player.faces[0]
    let value = player.values[0]
    let suit = player.suits[0]

    //if all suits are the same
    if player.suits.allSatisfy({$0 == suit}){
        //if all values are the same
        if player.values.allSatisfy({$0 == value}){
            //five of a kind
            return "Five of a kind", face
        }
        //sorts the array in numerical order, then checks if each value is equal to the previous value plus one
        if player.values.sorted{ $1 > $0 }.filter{ $1 == ($0 + 1)} == player.values {
            //if the hand is a royal flush
            if ["Ace", "King", "Queen", "Jack", "10"].allSatisfy[player.faces.contains]{
                //royal flush
                return "Royal flush", "Ace"
            }
            else {
                //flush five
                return "Flush five"
            }
        }
    }

    var pairCount: Int = 0

    for face in player.faces {
        //stores a count of cards in the array that have the same face.
        let countOfSameFaces = player.faces.filter { $0 == face }.count

        if countOfSameFaces == 4 {
            // Four of a kind
            return "Four of a kind"
        } else if countOfSameFaces == 3 {
            //iterates thru faces in hand
            for face in player.faces {
                //checks if the hand contains a pair
                let tempCount = player.faces.filter { $0 == face }.count //needs clearer name
                if tempCount == 2 {
                    //full house
                    return "Full house"
                }
            // Three of a kind
            }
        } else if countOfSameFaces == 2 {
            pairCount += 1
        }
    }
    if pairCount > 0{
        if pairCount > 1 {
            //two pairs
            return "Two pairs"
        }
        //pair
        return "Pair"
    } else {
        //high card
        return "High card"
    }

}
//poker hand conditions:
//Five of the same face (possible only in games with more than 1 deck) (Five of a kind)
//King, Queen, Jack, 10, and ace of the same suit (Royal flush)
//Five cards numerically consecutive of the same suit   (Straight Five)
//Four cards of the same face   (Four of a kind)
//Three cards of the same face, with the remaining two being the same face
//All cards of the same suit
//Five Cards numerically consecutive, but not of the same suit
//Three cards of the same face
//Two pairs of the same faces
//One pair
//if none of these is fulfilled, the highest card is counted.




//in the case of ties, the player with the highest face value wins.
//For a royal flush, or other identical hands, the pot is split.
//for a full house tie, the player with the higher three-of-a-kind wins.
func evaluateHands(){
    //card.value
}

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
func checkStatus(players: [Player]) -> Bool {
    var activePlayers: Int = players.count
    for (index, player) in players.enumerated() {
        if activePlayers <= 1 {
            declareWinner(players: players, winner: player, index: index)
            return false
        }
        if player.hand.isEmpty {
            activePlayers -= 1
        }

    }
    return true
}

//not yet implemented
func declareWinner(players: [Player], winner winningPlayer: Player, index: Int) {
    var potTotal: Int = 0
    for player in players {
        //takes the winning player's bet as well as every other player's bet. not sure that should happen! oh well
        potTotal += player.bet
    }
    potTotal -= winningPlayer.money
    print("Player \(index) wins $\(potTotal)")
    winningPlayer.money += potTotal
}


func initializeGame(decks numDecks: Int = 1, players numPlayers: Int = 4) {
    //Creates an array of Player objects 
    let discardPile = Deck()
    let mainDeck = Deck()
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
    runBettingRound(players: players, deck: mainDeck, pile: discardPile)
    
}