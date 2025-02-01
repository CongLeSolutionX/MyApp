//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

// MARK: - Previews
// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}


// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}

// MARK: - HomeView
struct Home : View {
    
    @State var index = 0
    @State var stories = [
        
        Story(id: 0, image: "p", offset: 0,title: "Thúy Kiều"),
        Story(id: 1, image: "p4", offset: 0,title: "Thúy Vân"),
        Story(id: 2, image: "p5", offset: 0,title: "Thúy Liễu...Ooop!🙊"),
        Story(id: 3, image: "p6", offset: 0,title: "Random Girl"),
]
    @State var scrolled = 0
    @State var index1 = 0
    
    var body: some View{
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack{
                
                HStack{
                    
                    Button(action: {}) {
                        
                        Image("menu")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        
                        Image("search")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                HStack{
                    
                    Text("Trending")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {}) {
                        
                        Image("dots")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .rotationEffect(.init(degrees: 90))
                    }
                }
                .padding(.horizontal)
                
                HStack{
                    
                    Text("Animated")
                        .font(.system(size: 15))
                        .foregroundColor(index == 0 ? .white : Color("Color1").opacity(0.85))
                        .fontWeight(.bold)
                        .padding(.vertical,6)
                        .padding(.horizontal,20)
                        .background(Color("Color").opacity(index == 0 ? 1 : 0))
                        .clipShape(Capsule())
                        .onTapGesture {
                            
                            index = 0
                        }
                    
                    Text("25+ Girls")
                        .font(.system(size: 15))
                        .foregroundColor(index == 1 ? .white : Color("Color1").opacity(0.85))
                        .fontWeight(.bold)
                        .padding(.vertical,6)
                        .padding(.horizontal,20)
                        .background(Color("Color").opacity(index == 01 ? 1 : 0))
                        .clipShape(Capsule())
                        .onTapGesture {
                            
                            index = 1
                        }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top,10)
                
                // Card View....
                
                ZStack{
                    
                    // Zstack Will Overlap Views So Last WIll Become First...
                    
                    ForEach(stories.reversed()){story in
                        
                        HStack{
                            
                            ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)){
                                
                                Image(story.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    // dynamic frame....
                                    // dynamic height...
                                    .frame(width: calculateWidth(), height: (UIScreen.main.bounds.height / 1.8) - CGFloat(story.id - scrolled) * 50)
                                    .cornerRadius(15)
                                    // based on scrolled changing view size...
                                    
                                
                                VStack(alignment: .leading,spacing: 18){
                                    
                                    HStack{
                                        
                                        Text(story.title)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    
                                    Button(action: {}) {
                                        
                                        Text("Chat with me")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.vertical,6)
                                            .padding(.horizontal,25)
                                            .background(Color("Color1"))
                                            .clipShape(Capsule())
                                    }
                                }
                                .frame(width: calculateWidth() - 40)
                                .padding(.leading,20)
                                .padding(.bottom,20)
                            }
                            .offset(x: story.id - scrolled <= 2 ? CGFloat(story.id - scrolled) * 30 : 60)
                            
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                        // adding gesture...
                        .offset(x: story.offset)
                        .gesture(DragGesture().onChanged({ (value) in
                            
                            withAnimation{
                                
                                // disabling drag for last card...
                                
                                if value.translation.width < 0 && story.id != stories.last!.id{
                                    
                                    stories[story.id].offset = value.translation.width
                                }
                                else{
                                    
                                    // restoring cards...
                                    
                                    if story.id > 0{
                                        
                                        stories[story.id - 1].offset = -(calculateWidth() + 60) + value.translation.width
                                    }
                                }
                                
                                
                            }
                            
                        }).onEnded({ (value) in
                            
                            withAnimation{
                            
                                if value.translation.width < 0{
                                    
                                    if -value.translation.width > 180 && story.id != stories.last!.id{
                                        
                                        // moving view away...
                                        
                                        stories[story.id].offset = -(calculateWidth() + 60)
                                        scrolled += 1
                                    }
                                    else{
                                        
                                        stories[story.id].offset = 0
                                    }
                                }
                                else{
                                    
                                    // restoring card...
                                    
                                    if story.id > 0{
                                        
                                        if value.translation.width > 180{
                                            
                                            stories[story.id - 1].offset = 0
                                            scrolled -= 1
                                        }
                                        else{
                                            
                                            stories[story.id - 1].offset = -(calculateWidth() + 60)
                                        }
                                    }
                                }
                            }
                            
                        }))
                    }
                }
                // max height...
                .frame(height: UIScreen.main.bounds.height / 1.8)
                .padding(.horizontal,25)
                .padding(.top,25)
                
                HStack{
                    
                    Text("Favourites")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {}) {
                        
                        Image("dots")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .rotationEffect(.init(degrees: 90))
                    }
                }
                .padding(.horizontal)
                .padding(.top,25)
                
                HStack{
                    
                    Text("Latest")
                        .font(.system(size: 15))
                        .foregroundColor(index1 == 0 ? .white : Color("Color1").opacity(0.85))
                        .fontWeight(.bold)
                        .padding(.vertical,6)
                        .padding(.horizontal,20)
                        .background(Color("Color1").opacity(index1 == 0 ? 1 : 0))
                        .clipShape(Capsule())
                        .onTapGesture {
                            
                            index1 = 0
                        }
                    
                    Text("9+ Stories")
                        .font(.system(size: 15))
                        .foregroundColor(index1 == 1 ? .white : Color("Color1").opacity(0.85))
                        .fontWeight(.bold)
                        .padding(.vertical,6)
                        .padding(.horizontal,20)
                        .background(Color("Color1").opacity(index1 == 01 ? 1 : 0))
                        .clipShape(Capsule())
                        .onTapGesture {
                            
                            index1 = 1
                        }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top,10)
                
                HStack{
                    
                    Image("p")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 250)
                        .cornerRadius(15)
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                .padding(.top,20)
                .padding(.bottom)
            }
        }
        .background(
        
            LinearGradient(gradient: .init(colors: [Color("top"),Color("bottom")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    func calculateWidth()->CGFloat{
        
        // horizontal padding 50
        
        let screen = UIScreen.main.bounds.width - 50
        
        // going to show first three cards
        // all other will be hidden....
        
        // scnd and third will be moved x axis with 30 value..
        
        let width = screen - (2 * 30)
        
        return width
    }
}


// Sample Data....

struct Story : Identifiable {
    
    var id : Int
    var image : String
    var offset : CGFloat
    var title : String
}
