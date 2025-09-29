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
        
    }
    func split() -> Void{

    }

}

print("The thing is currently a work in progress, but this should be where you can choose all the games from so put something here")
var choice:String = readLine()!
print("Your choice was \(choice)")