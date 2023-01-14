//
//  GridView.swift
//  SwiftUI-SC
//
//  Created by Babul Raj on 05/04/22.
//

import SwiftUI


struct GridView: View {
    @State var moveAray: [Move?] = Array(repeating: nil, count: 9)
   @State var isHumanPlayer: Bool = true
    @State var isBoardDisabled = false
    @State var isAlertTobeShown = false
    @State var alertItem: AlertItem?
   
    private var items = Array(1...1000).map { one in
        return "item\(one)"
    }
    
    let columns = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
               
                LazyVGrid(columns:columns, spacing: 5) {
                    ForEach(0..<9) { i in
                        
                        ZStack {
                            Circle()
                                .foregroundColor(.red)
                                .opacity(0.5)
                                .frame(width: (geometry.size.width/3)-10, height: (geometry.size.width/3)-10)
                            Image(systemName: moveAray[i]?.image ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            if !isAlreadySelected(for: i, array: moveAray) {
                                let move = Move(player: .man, index: i)
                                moveAray[i] = move
                                isBoardDisabled = true
                                
                                if checkIfWon(array: moveAray, player: .man) {
                                    print("Human wins")
                                    isBoardDisabled = false
                                    isAlertTobeShown = true
                                    return
                                }
                                
                                if checkForDraw(array: moveAray) {
                                    print("Draw")
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
                                    guard let compPosition = getComputerPosition(array: moveAray) else {return}
                                    let compMove = Move(player: .computer, index: compPosition)
                                    moveAray[compPosition] = compMove
                                    if checkIfWon(array: moveAray, player: .computer) {
                                        print("Computer wins")
                                        isBoardDisabled = false
                                        isAlertTobeShown = true
                                        return
                                    }
                                    
                                    if checkForDraw(array: moveAray) {
                                        print("Draw")
                                    }
                                    isBoardDisabled = false
                                    
                                }
                            }
                        }
                    }
                }.disabled(isBoardDisabled)
                
                Button {
                    self.moveAray = Array(repeating: nil, count: 9)
                    self.isHumanPlayer = true
                } label: {
                    Text("Reload")
                        .foregroundColor(.blue)
                }.padding()

                Spacer()
            }

            
        }.padding()
    }
    
    func isAlreadySelected(for index: Int, array: [Move?]) -> Bool {
        return array.contains { item in
            item?.index == index
        }
    }
    
    func getComputerPosition(array: [Move?]) -> Int? {
        let nonSelected = array.filter { item in
            item == nil
        }
        guard nonSelected.count > 0 else {return nil}
        
        var newPosition = Int.random(in: 0..<9)
        
        while isAlreadySelected(for: newPosition, array: array) {
            newPosition = Int.random(in: 0..<9)
        }
        
        return newPosition
        
    }
    
    func checkIfWon(array: [Move?], player: Plyer) -> Bool {
        let winPositions:Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let playerMoves = array.compactMap {
            $0
        }.filter { item in
            item.player == player
        }.map { item in
            item.index
        }
        
        let playerMoveSet = Set(playerMoves)
        
        for pattern in winPositions {
            if pattern.isSubset(of: playerMoveSet) {
                return true
            }
        }
        
        return false
    }
    
    func checkForDraw(array: [Move?]) -> Bool {
        return array.compactMap({ item in
            item
        }).count == 9
    }
}

enum Plyer {
    case man,
    computer
}

struct Move {
    var player: Plyer
    var index: Int
    var image: String {
        return self.player == .computer ? "circle" : "xmark"
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}


struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var buttonText: Text
}

struct AlertContext {
    let humanWin = AlertItem(title: Text("You Won"), message: Text("You are better than Computer"), buttonText: Text("Hell Yeah"))
    
    let computerWin = AlertItem(title: Text("AI Won"), message: Text("Your AI is  better than you"), buttonText: Text("Awesome"))
    
    let draw = AlertItem(title: Text("its Draw"), message: Text("Waht a battle"), buttonText: Text("Play again"))
}
