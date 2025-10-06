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
    var ready: Bool = false
    var name: String = "Unnamed"
    var handsum:Int = 0
        var splitted: Bool = false
        var hand2: [Card] = [Card]()//hand only used if user has split
    

    init(name Name: String) {
        self.name = Name
    }

    public func dealt(numCards numberOfCards: Int = 1, deck deckToUse: Deck){
        //deals the number of cards to the player from the selected deck
        for _ in 1...numberOfCards{
            //removes the card at the first index and appends it to the hand
            hand.append(deckToUse.removeCard(index: 0))
        }
    }

    public func hit(deck deckToUse: Deck) {
        hand.append(deckToUse.removeCard(index: 0))
    }
    public func stand() {
        ready = true
        print("\(name) has decided to stand")
    }
    public func doubleDown(deck deckToUse: Deck) {
        hand.append(deckToUse.removeCard(index: 0))
        stand()//an issue here
    }
    public func split() { //you can't split multiple times in a row
        
    }
    public func declare() -> Int{//for announcing the sum of the cards in hand is
        var sum = 0
        for i:Int in 0...hand.count-1{
            sum += hand[i].value
        }
        print("\(name) has a sum of \(sum)")
        handsum = sum
        return sum
    }
    public func question(deck deckToUse: Deck) -> Deck{//after eventually getting the choices, since all of these will be altering the inserted deck in some form, what is spat out are the cards remaining
        //this is going to be for questioning them about their action
        return Deck()
    }
    public func moneyset(amount change: Int = 0){
        balance += change
    }
}

public class Manager { //and all the empty husks cried out one word... 
    var players: [Player] = [Player]() //first member in this array will be the dealer, rest are standard players
    var numPlayers:Int = 0 
    var pot: Int = 0 //divide by numPlayers to find the bet to use for stand() and doubleDown() when called (when double down, multiply the pot by 2, as everyone now is forced to put in twice as much)

    public func raisePot(money amount: Int){
        pot += amount * numPlayers
        //respective amount needs to be subtracted from all players by iterating through the player list, do not mind if someone is negative yet

    }
    public func clear(){
        for _ in 1...20{
            print()
        }
        
    }
    public func BLACKJACK(){
      print("BLACKKKKKKKKKKJACKKKKKKKKKKKKKKKKKK!!!!!!!!!!!!!!!") 
    }
    public func checkName(name Name: String) -> String {
        if (Name != "Bot"){
            return Name
        }
        else{
            print("name is not allowed, try again")
            return checkName(name: readLine()!)
        }
    }
    public func generatePlayers() {
        if numPlayers <= 1{
            players = [Player]()
            for i in 1...numPlayers{
                print("what will be the name of player \(i)")
                players.append(Player(name: checkName(name: readLine()!)))
            }
        }
        
    }

    public func run() {
        var Pile:Deck = Deck()
    //the gameplay loop

//amount of players needed
        print("how many players are you going to be playing with (Minimum of 2 and Maximum of 7)")
        while numPlayers <= 1{
          
            if (numPlayers <= 7){
                numPlayers = Int(readLine()!)!
            }
            else{
                print("you have inputted above 7 players, please try again")
            }
        }
        print("You have chosen to play with \(numPlayers) real players!") 
        generatePlayers()
    
//the loop begins
    var done = false
    while !done {
        numPlayers = players.count
    //ask every player for their bet, take the highest bet and make everyone add it to the pot (without anyone going bankrupt, if someone is going to go bankrupt, turn them negative)
                            //this can be done within this function
        var maxVal: Int = 1
        for i:Int in 0...numPlayers-1 {
            print("your balance is \(players[i].balance)")
            print("what is your bet, \(players[i].name)? (minimum 1)")
            maxVal = max(maxVal, Int(readLine()!)!)
        }
        print("the amount each player must attempt to add is \(maxVal)")
        //deal out the cards
                            //also can be done within this function
            for i:Int in 0...numPlayers-1 {
                players[i].dealt(numCards: 2, deck: Pile)
            }
        //start with the end of the array and incrementing towards the dealer
        for i in stride(from: numPlayers-1, to: -1, by: -1) {
  
        //ask about what their action is after showing them their cards (raise pot if necessary ISSUE PRESENT WITH DOUBLE DOWN?)
                            //done within a function of the player class
            Pile = players[i].question(deck: Pile)
        //send a bunch of new lines to clear screen so the next player isn't spoiled
            clear()
        }
    //start comparing who has the highest value
        var pointer = 0
        for i:Int in 0...numPlayers-1{
            let playersum = players[i].declare()
            if playersum >= players[pointer].handsum{
                pointer = i
            }
        }
        //then iterate backwards, and see if there are any duplicates to force a pushback
        var pushback = false
        for i in stride(from: numPlayers-1, to: 0, by: -1) {
            if (players[pointer].handsum == players[i].handsum) && (pointer != i) {
                pushback = true
                break
            }
        }
    //whoever wins gets all the money
    if pushback == false{
        for i:Int in 0...numPlayers-1{
            players[i].moneyset(amount: -1 * (pot/numPlayers))
        }
        players[pointer].moneyset(amount: pot)
    }

    //if anyone is negative money they are removed from the game (make sure not to take bankrupt money as real money, and only take the balance of the player before they went bankrupt)
    for i:Int in 0...numPlayers-1{
        if players[i].balance<=0{
            players[pointer].moneyset(amount: players[i].balance)
            players.remove(at: i)
        }
    }
    //repeat asking for bets until only one player remains
        if numPlayers <= 1 {
            done = true
        }
    }
//the loop ends


//say who won and how much money they got
//MAY EVENTUALLY NEED TO MAKE IT SO THAT IT JUST ITERATES AND FIND WHOEVER HAS THE HIGHEST SCORE
print("\(players[0].name) has won the game of blackjack with \(players[0].balance)")
    }    
}




