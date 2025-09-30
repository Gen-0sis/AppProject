//This file is meant to contain a usable base for card games
//Currently it contains a basic implementation of a deck of cards and a player class
//The deck can create a standard 52 card deck, remove cards, and add cards
//The player can deal themselves a specified number of cards from a given deck
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

    
    func createDeck(numDecks numberOfDecks: Int = 1) -> [Card] {
        //Iterates through the number of 52 card decks to create, by default 1
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
//use for games which have hand types
enum hands: String {
    case royalFlush = "Royal flush"
    case straightFlush = "Straight flush"
    case fiveOfAKind = "Five of a kind"
    case fourOfAKind = "Four of a kind"
    case fullHouse = "Full house"
    case flush = "Flush"
    case straight = "Straight"
    case threeOfAKind = "Three of a kind"
    case twoPair = "Two pair"
    case onePair = "One pair"
    case highCard = "High card"
}