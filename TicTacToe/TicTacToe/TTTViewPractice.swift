//
//  TTTViewPractice.swift
//  SwiftUI-SC
//
//  Created by Babul Raj on 28/05/22.
//

import SwiftUI


struct TTTViewPractice: View {
    var column = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
    @State var moveArray: [Move1?] = Array(repeating: nil, count: 9)
    @State var isComp = false
    @State var disableBoard = false
    @State var alertItem: AlertItem?
 
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                LazyVGrid(columns: column,spacing: 10) {
                    getCircles(geometry: geometry)
                }.padding()
                
                Button("Reload") {
                    resetBoard()
                }
                Spacer()
            }.alert(item: $alertItem) { item in
                Alert(title: item.title, message: item.message, dismissButton: .default(Text("Ok"), action: {
                    self.resetBoard()
                }))
            }
        }
    }
    
    fileprivate func getCircles(geometry: GeometryProxy) -> some View {
        return ForEach(0..<9) {
            item in
            ZStack {
                Circle()
                    .frame(width: (geometry.size.width/3)-15, height: (geometry.size.width/3)-15)
                    .foregroundColor(.red)
                    .onTapGesture {
                        handleTap(index: item)
                    }.disabled(disableBoard)
                if  isPositionOccupied(position: item) {
                    Text(moveArray[item]?.player.getText() ?? "")
                }
            }
        }
    }
    
    private func isPositionOccupied(position: Int) -> Bool {
        return moveArray.filter { move in
            move?.index == position
        }.count > 0
    }
    
    private func handleTap(index: Int) {
        guard isPositionOccupied(position: index) else {
            let newEvent = Move1(player: .Person, index: index)
            moveArray[index] = newEvent
            if checkForWin() {
                return
            }
            checkForDraw()
            disableBoard = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
                makeCompMove()
                if checkForWin() {
                    return
                }
                checkForDraw()
                disableBoard = false
            }
           
            return
        }
    }
    
    private func resetBoard() {
        moveArray = Array(repeating: nil, count: 9)
        disableBoard = false
    }
    
    private func makeCompMove() {
        let winPositions:Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        // Win if can
        let computerPositions = moveArray.filter { move in
            move?.player == .Computer
        }.compactMap { move in
            return move?.index
        }
        
        for pattern in winPositions {
            let positions = pattern.subtracting(computerPositions)
            
            if positions.count == 1 {
                let isVailable =  !isPositionOccupied(position: positions.first!)
                if isVailable {
                    let newEvent = Move1(player: .Computer, index: positions.first!)
                    moveArray[positions.first!] = newEvent
                    return
                }
            }
        }
        
        // If can't win, block
        
        let humanrPositions = moveArray.filter { move in
            move?.player == .Person
        }.compactMap { move in
            return move?.index
        }
        
        for pattern in winPositions {
            let positions = pattern.subtracting(humanrPositions)
            
            if positions.count == 1 {
                let isVailable =  !isPositionOccupied(position: positions.first!)
                if isVailable {
                    let newEvent = Move1(player: .Computer, index: positions.first!)
                    moveArray[positions.first!] = newEvent
                    return
                }
            }
        }
        
        //Pick middle
        
        if !isPositionOccupied(position: 4) {
            let newEvent = Move1(player: .Computer, index: 4)
            moveArray[4] = newEvent
            return
        }
        
        
        // Pick Random
        var random: Int?
        while true {
            guard moveArray.filter({ item in
                item == nil
            }).count > 0 else {return}
            random = (0..<9).randomElement()
            
            if let rendomLoc = random, moveArray[rendomLoc] == nil  {
                let newEvent = Move1(player: .Computer, index: rendomLoc)
                moveArray[rendomLoc] = newEvent
                return
            }
        }
    }
    
    private func checkForWin() -> Bool {
        let winPositions:Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
        
        let compPositions = moveArray.filter { move in
            move?.player == .Computer
        }.compactMap { move in
            return move?.index
        }
        
        let compSet = Set(compPositions)
        
        let personPosition = moveArray.filter { move in
            move?.player == .Person
        }.compactMap { move in
            return move?.index
        }
        
        let personSet = Set(personPosition)
        
        for pattern in winPositions {
            if pattern.isSubset(of: compSet) {
                disableBoard = true
                alertItem = AlertContext().computerWin
                return true
                
            } else if pattern.isSubset(of: personSet) {
                disableBoard = true
                alertItem = AlertContext().humanWin
                return true
            }
        }
        
        return false
    }
    
    func checkForDraw() {
        if moveArray.compactMap({ item in
            item
        }).count == 9 {
            disableBoard = true
            alertItem = AlertContext().draw
        }
    }
}

struct Move1 {
    var player: Player
    var index: Int
}

enum Player {
    case Person,
         Computer
    
    func getText() -> String {
        switch self {
        case .Person:
            return "You"
        case .Computer:
            return "Computer"
        }
    }
}

struct TTTViewPractice_Previews: PreviewProvider {
    static var previews: some View {
        TTTViewPractice()
    }
}


