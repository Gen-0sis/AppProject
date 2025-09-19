
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
    var SUITS: [String] = ["Spades", "Diamonds", "Clubs", "Hearts"]
    var FACES: [String] = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
    var VALUE_MAP: [String: Int] = ["Ace": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,"Jack": 10, "Queen": 10, "King": 10]
    
    var cards: [Card] = [Card]()

    
    func createDeck() -> [Card] {

        //Iterates through each suit, and for each suit each face.
        for suit in SUITS {
            for face in FACES {
                //Creates cards and adds them to the cards array
                cards.append(Card(suit: suit, face: face, value: VALUE_MAP[face]!))
            }

        }
        return cards
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

}

class Manager { //and all the empty husks cried out one word... 
    var players: [Player] = [Player]() //first member in this array will be the dealer, rest are standard players
    var numPlayers:Int = 0;
    func beginBJ(){ //how to initiate a game of blackjack
        print("how many players are you going to be playing with")
        numPlayers = Int(readLine()!)!;
        print("You have chosen to play with \(numPlayers) real players!");

    }
}

class Player {
    //hand is an empty array of card objects
    var hand: [Card] = [Card]()


    func deal(numCards numberOfCards: Int = 1, deck deckToUse: Deck) -> [Card] {
        //deals the number of cards to the player from the selected deck
        for _ in 1...numberOfCards{
            //removes the card at the first index and appends it to the hand
            hand.append(deckToUse.removeCard(index: 0))
        }

        return hand
    }

    func hit() -> Void{
        //deal();
    }
    func split() -> Void{

    }
    func BLACKJACK() -> Void{
        print("BLACKKKKKKKKKKJACKKKKKKKKKKKKKKKKKK!!!!!!!!!!!!!!!");
    }

}