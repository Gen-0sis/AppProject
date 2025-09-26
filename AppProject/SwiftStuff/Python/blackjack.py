import random

class Card:
    def __init__(self, suit, face, value):
        self.suit = suit
        self.face = face
        self.value = value

    def __str__(self):
        return f"{self.face} of {self.suit}"


#Creates one deck of 52 cards
def createDeck():
    deck = []
    suits = "Spades", "Diamonds", "Clubs", "Hearts" 
    faces = "Ace","2","3","4","5","6","7","8","9","10", "Jack", "Queen", "King"

    for suit in suits:
        value = 1
        for face in faces:
            if face in ("Jack", "Queen", "King"):
                card = Card(suit, face, 10)
                deck.append(card)
            else:
                card = Card(suit, face, value)
                deck.append(card)
                value += 1
    return deck

#Shuffles an array
def shuffle(deck): 
    random.shuffle(deck)
    return deck

#Creates a shuffled draw pile with the specified number of decks 
def createDrawPile(num):
    drawPile = []
    for i in range(num):
        deck = createDeck()
        #cant append the deck to the pile all at once, as objects become strings
        for item in deck:        
            drawPile.append(item)
    shuffle(drawPile)
    return drawPile

#Starts the game by creating each player and dealing out 2 cards to them, and one to the dealer.
def startGame(numPlayers, drawPile):
    players = {}
    bets = {}
    for playerNum in range(numPlayers): 
        bets[f"player{playerNum}"] = None
        players[f"player{playerNum}"] = [drawPile.pop(0)]

    players["dealer"] = [drawPile.pop(0)]

    for playerNum in range(numPlayers):
        players[f"player{playerNum}"].append(drawPile.pop(0))

    players["dealer"].append(drawPile.pop(0))

    return players, bets

def dealCard(playerKey, players, drawPile):
    players[playerKey].append(drawPile.pop(0))


def countTotal(playerKey, players):
    handTotal = 0
    aceCount = 0
    if len(players[playerKey]) == 0:
        return handTotal
    for cardIndex in range(len(players[playerKey])):
        if (players[playerKey][cardIndex].face) == "Ace":
            aceCount += 1
        handTotal += (players[playerKey][cardIndex].value)
    for i in range(aceCount):
        if  handTotal + 10 <= 21:
            handTotal += 10
    

    return handTotal

def hit(playerKey, players, drawPile):
    dealCard(playerKey, players, drawPile)
    return countTotal(playerKey, players)

def bust(playerKey, players, drawPile):
    if playerKey in players:
        drawPile.extend(players[playerKey])  # Adds player's cards back to drawPile
        shuffle(drawPile)                     # shuffles the drawPile
        players[playerKey] = [] 

def blackJack():
        print("BLACKJACK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

def split(playerKey, players, drawPile, bets):
    # Assume exactly 2 cards and both same face
    #Retrieves card objects and stores them as variables
    card1 = players[playerKey][0]
    card2 = players[playerKey][1]

    #Creates names for the new original hand and split
    handA = f"{playerKey}"
    handB = f"{playerKey}'s Split"

    #Creates the hands in the dictionary and gives them a card each.
    players[handA] = [card1]
    players[handB] = [card2]

    #duplicates the player's bet to the new hand
    bets[handB] = bets[playerKey]
    
    # Deal one more card to each hand
    hit(handA, players, drawPile)
    hit(handB, players, drawPile)

    return [handA, handB]  # Return new hand names for iteration

def placeBet(playerKey, players, bets, betAmount):
        bets[playerKey] = betAmount

#Contains most of the actual hand logic (Not final scoring logic)
def takeInput(playerKey, players, drawPile, bets):
    while not isinstance(bets[playerKey], int):
        try:
            bet = int(input("Place your bet. Maximum of 500 dollars, minimum of 2. \n"))
            if 2 <= bet <= 500:
                bets[playerKey] = bet
            else:
                print("Bet out of range. Try again.")
        except ValueError:
            print("Invalid input, try again.")
    while countTotal(playerKey, players) < 21:
        match input("what would you like to do?  (hit/pass/double down): \n"):
            case "hit":
                handScore = hit(playerKey, players, drawPile)
                if handScore == 21:
                    blackJack()
                    break
                print(f"New total: {handScore}") 
                if players[playerKey]:
                    print(f"Newest card: {getCardInfo(playerKey, players, -1)}")
                if handScore > 21:
                    print("Bust! you went over 21.")
                    bust(playerKey, players, drawPile)
                    break
            case "pass":
                print("Passed!")
                break
            case "double down":
                if len(players[playerKey]) == 2:
                    bets[playerKey]*=2
                    print(f"Doubled down! new bet: {bets[playerKey]}")
                    hit(playerKey, players, drawPile)
                    break
            case _:
                print("invalid option")

def getCardInfo(playerKey, players, cardIndex):
    return f"{players[playerKey][cardIndex]}"

#Checks for blackjacks and splits, calls takeInput
#Run once for each player
def runPlayerTurn(playerNum, players, drawPile, bets):
    playerKey = f"player{playerNum}"
    print(f"Player {playerNum +1}'s turn")
    if countTotal(playerKey, players) == 21:
        blackJack()
        return

    print(f"Player {playerNum+1}'s hand:")
    for cardIndex in range(len(players[playerKey])):
        print(getCardInfo(playerKey, players, cardIndex))

    if players[playerKey][0].face == players[playerKey][1].face:
        if input("Would you like to split? Y/N: ").upper() == "Y":
            splitKeys = split(playerKey, players, drawPile, bets)
            firstSplit = True
            for splitKey in splitKeys:
                if firstSplit:
                    print("\nYour split: ")
                    firstSplit = False
                else:
                    print("\nYour hand: ")
                for cardIndex in range(len(players[splitKey])):
                    print(getCardInfo(splitKey, players, cardIndex))
                takeInput(splitKey, players, drawPile, bets)
            return 
        else:
            takeInput(playerKey, players, drawPile, bets)
            return
    else:
        takeInput(playerKey, players, drawPile, bets)
    return

def runDealerTurn(players, drawPile):
    #Sums up dealer's total and returns it.
    playerKey = "dealer"
    print(f"Dealer's other card: {getCardInfo(playerKey, players, -1)}")
    while countTotal(playerKey, players) < 17:
        hit(playerKey, players, drawPile)
        print(f"Dealer's new card: {getCardInfo(playerKey, players, -1)}")
        print(f"Dealer's new total: {countTotal(playerKey, players)}")
    dealerTotal = countTotal(playerKey, players)
    if dealerTotal > 21:
        print("Dealer busts!")
    elif dealerTotal == 21:
        print("Dealer gets blackjack!")
    else:
        print(f"Dealer's final total: {dealerTotal}")

    return dealerTotal

def endGame(players, drawPile, dealerScore, bets):
    #Sums the number of keys in the dictionary which start with "player" (excludes dealer) and do not contain "split"
    numPlayers = sum(1 for key in players if key.startswith("player") and "Split" not in key)
    
    #Iterates through real players, which are at the front of the dictionary as they are created before the dealer and before splits
    for i in range(numPlayers):
        baseKey = f"player{i}"
        splitKey = f"{baseKey}'s Split"

        baseTotal = countTotal(baseKey, players)
        hasSplit = splitKey in players
        splitTotal = countTotal(splitKey, players) if hasSplit else None

        print(f"\nPlayer {i + 1}'s score: {baseTotal}", end='')
        if hasSplit:
            print(f" | Split: {splitTotal}")
        else:
            print()

        # -- Base hand results --

        if baseTotal == 0:
            print(f"Player {i + 1} busted, and lost their ${bets[baseKey]} bet.")
            bets[baseKey] = 0
                
        else:
            match dealerScore:
                case _ if dealerScore > 21:
                    print(f"Player {i + 1} wins! They won ${bets[baseKey]} because the dealer busted.")
                    bets[baseKey] *= 2
                case _ if dealerScore > baseTotal:
                    print(f"Player {i + 1} loses their ${bets[baseKey]} bet.")
                    bets[baseKey] = 0
                case _ if dealerScore < baseTotal:
                    print(f"Player {i + 1} wins! They won ${bets[baseKey]}")
                    bets[baseKey] *= 2
                case _ if dealerScore == baseTotal:
                    print(f"Player {i + 1} ties the house and keeps their ${bets[baseKey]} bet.")

        # -- Split hand results --
        if hasSplit:
            match dealerScore:
                case _ if dealerScore > 21:
                    print(f"Player {i + 1}'s split wins! They won ${bets[splitKey]} because the dealer busted.")
                    bets[splitKey] *= 2
                case _ if dealerScore > splitTotal:
                    print(f"Player {i + 1}'s split loses their ${bets[splitKey]} bet.")
                    bets[splitKey] = 0
                case _ if dealerScore < splitTotal:
                    print(f"Player {i + 1}'s split wins! They won ${bets[splitKey]}")
                    bets[splitKey] *= 2
                case _ if dealerScore == splitTotal:
                    print(f"Player {i + 1}'s split ties the house and they keep their ${bets[splitKey]} bet.")


# ---------- Game Execution ----------
def main():
    while True:
        try:
            numPlayers = int(input("Enter the number of players: "))
            if numPlayers >= 1:
                break
        except ValueError:
            pass

    while True:
        try:
            numDecks = int(input("Enter the number of decks: "))
            if numDecks >= 1:
                break
        except ValueError:
            pass

    drawPile = createDrawPile(numDecks)
    players, bets = startGame(numPlayers, drawPile)

    for playerNum in range(len(players)-1): #range minus one because the dealer is part of players
        print(f"Dealer's card: {getCardInfo('dealer', players, 0)}")
        runPlayerTurn(playerNum, players, drawPile, bets)

    dealerScore = runDealerTurn(players, drawPile)
    endGame(players, drawPile, dealerScore, bets)

if __name__ == "__main__":
    main() 

