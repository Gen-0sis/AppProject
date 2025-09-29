
public class Card {
    var suit: String = ""
    var face: String = ""
    var value: Int = 0

    init(suit: String, face: String, value:Int) {
        self.suit = suit
        self.face = face
        self.value = value
    }

    public func getInfo() -> String {
        return "\(face) of \(suit)"
    }
}

public class Deck {
    var SUITS: [String] = ["Spades", "Diamonds", "Clubs", "Hearts"]
    var FACES: [String] = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
    var VALUE_MAP: [String: Int] = ["Ace": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,"Jack": 10, "Queen": 10, "King": 10]
    
    var cards: [Card] = [Card]()

    
    public func createDeck() -> [Card] {

        //Iterates through each suit, and for each suit each face.
        for suit in SUITS {
            for face in FACES {
                //Creates cards and adds them to the cards array
                cards.append(Card(suit: suit, face: face, value: VALUE_MAP[face]!))
            }

        }
        return cards
    }

    public func removeCard(index indexToRemove: Int) -> Card {
        //removes a card from the deck using its index in the deck and returns its value
        let tempcard: Card = cards[indexToRemove]
        cards.remove(at: indexToRemove)
        return tempcard
        //use for deal and hit
    }

    public func addCard(card cardToAdd: Card) -> Void {
        //adds a card to the deck
        cards.append(cardToAdd)
    }

}


public class Bot {//should be an extension of players and include all of player lines of logic here

}

public class Player {
    //hand is an empty array of card objects
    var hand: [Card] = [Card]()
    var balance: Int = 500
    var ready: Bool = false;
    var name: String = "Unnamed"
    public func dealt(numCards numberOfCards: Int = 1, deck deckToUse: Deck) -> [Card] {
        //deals the number of cards to the player from the selected deck
        for _ in 1...numberOfCards{
            //removes the card at the first index and appends it to the hand
            hand.append(deckToUse.removeCard(index: 0))
        }
        return hand
    }

    public func hit(deck deckToUse: Deck) {
        hand.append(deckToUse.removeCard(index: 0))
    }
    public func stand(bet Money: Int) {
        ready = true
        balance -= Money
        print("\(name) has decided to stand")
    }
    public func doubleDown(deck deckToUse: Deck, bet Money: Int) {
        hand.append(deckToUse.removeCard(index: 0))
        stand(bet: Money)//an issue here
    }
    public func split() {
        
    }
    

}

var Pile:Deck = Deck()

public class Manager { //and all the empty husks cried out one word... 
    var players: [Player] = [Player]() //first member in this array will be the dealer, rest are standard players
    var numPlayers:Int = 0 
    var pot: Int = 0 //divide by numPlayers to find the bet to use for stand() and doubleDown() when called (when double down, multiply the pot by 2, as everyone now is forced to put in twice as much)

    public func raisePot(money amount: Int){
        pot += amount * numPlayers
        //respective amount needs to be subtracted from all players


    }
    
    public func beginBJ(){ //how to initiate a game of blackjack
        print("how many players are you going to be playing with")
        numPlayers = Int(readLine()!)! 
        print("You have chosen to play with \(numPlayers) real players!") 
    }
    public func beginRound() {

    }
    public func endRound() {//a measure of player values (find the maximum value, but may need to see if there is a tie), then who gets how much money

    }
    public func BLACKJACK() -> Void{
      print("BLACKKKKKKKKKKJACKKKKKKKKKKKKKKKKKK!!!!!!!!!!!!!!!") 
    }
    
}


//the gameplay loop

//amount of players needed

//ask every player for their bet, take the highest bet and make everyone add it to the pot (without anyone going bankrupt, if someone is going to go bankrupt, turn them negative)
//deal out the cards

//start with the end of the array

//ask about what their action is after showing them their cards (raise pot if necessary)
//decrease the array
//send a bunch of new lines to clear screen so the next player isn't spoiled

//repeat previous 3 steps (starting from line 133 to line 135)

//display the cards of everyone
//whoever wins gets all the money
//if anyone is negative money they are removed from the game (make sure not to take bankrupt money as real money, and only take the balance of the player before they went bankrupt)

//go back to line 128 until satisfactory results (when only one player remains)

//then end game 
//say who won and how much money they got

