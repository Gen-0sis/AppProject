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
    
    var numDecks: Int = 1
    var cards: [Card] = [Card]()

    
    func createDeck() -> Deck {

        //Iterates through each suit, and for each suit each face.
        for suit in SUITS {
            for face in FACES {
                //Creates cards and adds them to 
                cards.append(Card(suit: suit, face: face, value: VALUE_MAP[face]!))
            }

        }


        return Deck
    }
}


class Player {
    //hand is an empty array of card objects
    var hand: [Card] = [Card]()


    func hit() -> Void{
        
    }
    func split() -> Void{

    }

}