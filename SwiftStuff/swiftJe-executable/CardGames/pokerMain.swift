//Poker game main file
//TODO
//Must create 2 52 card decks and shuffle them together
//create discard pile
//Deal 5 cards to each player
//take bets from each player, using poker betting rules (players must bet at least the amount of the previous bet, can fold, can check if no bet has been made)
//? Add Ante functionality
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
    let VALUE_MAP: [String: Int] = ["Ace": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,"Jack": 10, "Queen": 10, "King": 10]
    
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
    var hand: [Card] = [Card]()
    //placeholder values for money and bet
    var money: Int = 1000
    var bet: Int = 0


    func deal(numCards numberOfCards: Int = 1, deck deckToUse: Deck) -> [Card] {
        //deals the number of cards to the player from the selected deck
        for _ in 1...numberOfCards{
            //removes the card at the first index and appends it to the hand
            hand.append(deckToUse.removeCard(index: 0))
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
        //not currently applicable as each player has equal money, but will be useful in future if players can have different amounts of money
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

 
func runBettingRound(players:[Player], deck mainDeck: Deck, pile discardPile: Deck, anteAmount: Int = 0) -> Void {
    //runs a betting round for the given players, using the given deck and discard pile
    //anteAmount is the amount each player must bet at the start of the round, defaults to 0
    //currently does not handle end of round logic (i.e. all but one player folding)
    //also does not handle betting rounds after the first, where players can check if no bet has been made
    //this is a basic implementation to test the betting functions
    var currentBet: Int = anteAmount
    //playerStatus array will contain a boolean for each player, true if they are still in the round, false if they have folded, and their bet amount
    var playerStatus: [(Bool, Int)] = [(Bool, Int)]()
    var betsNotEqual: Bool = true

    for player in players {
        playerStatus.append((true, 0))
    }


    while betsNotEqual {
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
                        playerStatus[index].0 = false

                    case "raise":
                        print("How much would you like to raise?")
                        if let raiseInput = readLine(), let raiseAmount = Int(raiseInput) {
                            if player.raise(previousBet: currentBet, raiseAmount: raiseAmount) {
                                currentBet += raiseAmount
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


func initializeGame(decks numDecks: Int = 1, players numPlayers: Int = 4) {
    //Creates an array of Player objects 
    var discardPile = Deck()
    var mainDeck = Deck()
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