//
//  ContentView.swift
//  firstAppHopefullyEmoTune
//
//  Created by Admin on 8/12/24.

import SwiftUI
import PhotosUI
import CoreML
import AVKit
import AVFoundation

//my attempt to brute force the decoding of the http POST request
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

struct ContentView: View {
    
    let openAiApiKey = "INSERT API KEY HERE"
    
    //@State var imageFilename = "testSadImage"
    
    @State var outputString = ""
    
    @State var selectedEmotion = "LOVE MEEEE"
    
    @FocusState var isFocused: Bool
    
    //for the photo picker
    @State var pickerItem: PhotosPickerItem?
    @State var selectedImage: Image?
    
    //for the text editor and call-making
    @State private var messageText: String = ""
    @State var messages: [String] = ["Welcome to emoTune!", "Please upload a picture for analysis and select an emotion to practice."]
    @State var hiddenMessages: [String] = [""]
    @State var prompt: String = ""
    @State var response: String = ""
    
    //for the UI
    let neutralColor = Color(red: 0.8, green: 0.8, blue: 0.8)
    let happyColor = Color(red: 0.9, green: 0.8, blue: 0.0)
    let sadColor = Color(red: 0.7, green: 0.8, blue: 1.0)
    let surpriseColor = Color(red: 1.0, green: 0.8, blue: 0.5)
    let fearColor = Color(red: 0.75, green: 0.65, blue: 1.0)
    let disgustColor = Color(red: 0.65, green: 0.95, blue: 0.6)
    let angerColor = Color(red: 1.0, green: 0.75, blue: 0.65)
    
    let neutralColor2 = Color(red: 0.4, green: 0.4, blue: 0.4)
    let happyColor2 = Color(red: 0.8, green: 0.65, blue: 0.0)
    let sadColor2 = Color(red: 0.15, green: 0.4, blue: 0.8)
    let surpriseColor2 = Color(red: 0.8, green: 0.55, blue: 0.0)
    let fearColor2 = Color(red: 0.4, green: 0.15, blue: 0.9)
    let disgustColor2 = Color(red: 0.0, green: 0.6, blue: 0.125)
    let angerColor2 = Color(red: 0.725, green: 0.0, blue: 0.0)
    
    @State var appColor1: Color = Color(red: 0.7, green: 0.7, blue: 0.7)
    @State var appColor2: Color = Color(red: 0.0, green: 0.4, blue: 0.9)
    
    //More UI stuff
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    @State private var showHelpSheet = false
    @State private var showEmoSheet = false
    @State private var showCamSheet = true
    @State var frameHeight = UIScreen.main.bounds.height * 1/2
    @State var textY: CGFloat = CGFloat(0)
    @State var keyboardHeight: CGFloat = CGFloat(0)
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    //logging view stuff
    @AppStorage("datesGoalHit") @Storage var datesGoalHit: [String] = []
    @State var datesGoalHitStruct: [Day] = []
    //@AppStorage("todayDate") var todayDate: String = ""
    @State var todayDate: String = ""
    
    @AppStorage("timeToHitGoal") var timeToHitGoal: Int = 600
    @AppStorage("totalMins") var totalMins: Double = 0.0
    @AppStorage("daysGoalHitCount") var daysGoalHitCount: Int = 0
    @AppStorage("daysLoggedIn") var daysLoggedIn: Int = 0
    @AppStorage("daysLoggedInArr") @Storage var daysLoggedInArr: [String] = ["test"]
    @AppStorage("goalHit") var goalHit: Bool = false
    @State var shouldShowGoalHit: Bool = false
    @State var shouldShowLogging: Bool = false
    
    
    let formatter = DateFormatter()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //Recommended videos for each emotion (or at least they will be!)
    @State var currentVideo: String = ""
    
    struct Vid: Identifiable {
        let emotion: String
        var id: String { emotion }
    }
    
    private var currentVids: [Vid] = [
        Vid(emotion: "")
    ]
    
    private let neutralVids: [Vid] = [
        Vid(emotion: "neutral")
    ]
    
    private let happyVids: [Vid] = [
        Vid(emotion: "smile")
    ]
    
    private let sadVids: [Vid] = [
        Vid(emotion: "eyebrowsFurrowUp"),
        Vid(emotion: "mouthCornersDown"),
        Vid(emotion: "sad")
    ]
    
    private let surpriseVids: [Vid] = [
        Vid(emotion: "eyesWiden"),
        Vid(emotion: "surprise")
    ]
    
    private let fearVids: [Vid] = [
        Vid(emotion: "eyebrowsFurrowUpEyesWiden"),
        Vid(emotion: "eyebrowsFurrowUp"),
        Vid(emotion: "eyesWiden"),
        Vid(emotion: "fear")
    ]
    
    private let disgustVids: [Vid] = [
        Vid(emotion: "noseFlareDisgust"),
        Vid(emotion: "eyebrowsFurrowUp"),
        Vid(emotion: "disgust")
    ]
    
    private let angerVids: [Vid] = [
        Vid(emotion: "noseFlare"),
        Vid(emotion: "eyebrowsFurrowDown"),
        Vid(emotion: "anger")
    ]
    
    @State var quickEmo: Int = 10
    @State private var selection: Int = 0
    
    var body: some View {
        
        TabView(selection: $selection) {
            
            //Start main tab
            GeometryReader { geoProxy in
                
                let bottomInset = geoProxy.safeAreaInsets.bottom
                
                ZStack {
                    
                    Color.clear
                        //.frame(width: .infinity, height: .infinity)
                    
                    appColor1.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isFocused = false
                        }
                    
                    VStack {
                        
                        Spacer()
                        
                        //Text("Supposed date: " + formatter.string(from: Date.now) + "?")
                        
                        selectedImage?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth/2, height: screenWidth/2, alignment: .center)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                        
                        if (selectedEmotion != "LOVE MEEEE") {
                            HStack {
                                
                                Text("You are trying to show: ")
                                
                                Menu {
                                    Button ("Neutrality 😶") {
                                        selectedEmotion = "Neutrality 😶"
                                        quickEmo = 0
                                        appColor1 = neutralColor
                                        appColor2 = neutralColor2
                                    }
                                    Button ("Happiness 😊") {
                                        selectedEmotion = "Happiness 😊"
                                        quickEmo = 1
                                        appColor1 = happyColor
                                        appColor2 = happyColor2
                                    }
                                    Button ("Sadness ☹️") {
                                        selectedEmotion = "Sadness ☹️"
                                        quickEmo = 2
                                        appColor1 = sadColor
                                        appColor2 = sadColor2
                                    }
                                    Button ("Surprise 😯") {
                                        selectedEmotion = "Surprise 😯"
                                        quickEmo = 3
                                        appColor1 = surpriseColor
                                        appColor2 = surpriseColor2
                                    }
                                    Button ("Fear 😣") {
                                        selectedEmotion = "Fear 😣"
                                        quickEmo = 4
                                        appColor1 = fearColor
                                        appColor2 = fearColor2
                                    }
                                    Button ("Disgust 😖") {
                                        selectedEmotion = "Disgust 😖"
                                        quickEmo = 5
                                        appColor1 = disgustColor
                                        appColor2 = disgustColor2
                                    }
                                    Button ("Anger 😠") {
                                        selectedEmotion = "Anger 😠"
                                        quickEmo = 6
                                        appColor1 = angerColor
                                        appColor2 = angerColor2
                                    }
                                    
                                } label: {
                                    Text(selectedEmotion)
                                }
                            }
                        } else {
                            Menu {
                                Button ("Neutrality 😶") {
                                    selectedEmotion = "Neutrality 😶"
                                    quickEmo = 0
                                    appColor1 = neutralColor
                                    appColor2 = neutralColor2
                                }
                                Button ("Happiness 😊") {
                                    selectedEmotion = "Happiness 😊"
                                    quickEmo = 1
                                    appColor1 = happyColor
                                    appColor2 = happyColor2
                                }
                                Button ("Sadness ☹️") {
                                    selectedEmotion = "Sadness ☹️"
                                    quickEmo = 2
                                    appColor1 = sadColor
                                    appColor2 = sadColor2
                                }
                                Button ("Surprise 😯") {
                                    selectedEmotion = "Surprise 😯"
                                    quickEmo = 3
                                    appColor1 = surpriseColor
                                    appColor2 = surpriseColor2
                                }
                                Button ("Fear 😣") {
                                    selectedEmotion = "Fear 😣"
                                    quickEmo = 4
                                    appColor1 = fearColor
                                    appColor2 = fearColor2
                                }
                                Button ("Disgust 😖") {
                                    selectedEmotion = "Disgust 😖"
                                    quickEmo = 5
                                    appColor1 = disgustColor
                                    appColor2 = disgustColor2
                                }
                                Button ("Anger 😠") {
                                    selectedEmotion = "Anger 😠"
                                    quickEmo = 6
                                    appColor1 = angerColor
                                    appColor2 = angerColor2
                                    
                                }
                                
                            } label: {
                                Text("Select an emotion to practice.")
                            }
                        }
                        
                        Text("_____________________________________")
                            .padding(EdgeInsets(top: 5, leading: 0, bottom: 15, trailing: 0))
                            .foregroundStyle(appColor1)
                        
                        //messaging ChatGPT
                        
                        VStack {
                            
                            ScrollView {
                                    ForEach(messages, id: \.self) { message in
                                        if message.contains("[USER]") {
                                            let newMessage = message.replacingOccurrences(of: "[USER]", with: "")
                                            
                                            HStack {
                                                Spacer()
                                                Text(newMessage)
                                                    .padding()
                                                    .background(appColor1)
                                                    .cornerRadius(10)
                                                    .padding(.bottom, 10)
                                            }
                                        } else {
                                            HStack {
                                                Text(message)
                                                    .padding()
                                                    .background(appColor1.opacity(0.3))
                                                    .cornerRadius(10)
                                                    .padding(.bottom, 10)
                                                Spacer()
                                            }
                                            
                                        }
                                    }
                                    .rotationEffect(.degrees(180))
                            }
                            .rotationEffect(.degrees(180))
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                isFocused = false
                            }
                        
                        HStack {
                            TextField("Ask a question here", text: $messageText)
                                .padding()
                                .background(Color.white)//.opacity(0.1))
                                .foregroundStyle(Color.black)
                                .cornerRadius(10)
                                .focused($isFocused)
                                .onSubmit {
                                    Task {
                                        isFocused = false
                                        await sendMessage(message: messageText)
                                    }
                                }
                            
                            //analyze the image button
                            if (selectedImage != nil && selectedEmotion != "LOVE MEEEE") {
                                
                                Button {
                                    
                                    Task {
                                        await analyzeTheResult()
                                    }
                                    
                                } label: {
                                    Image(systemName: "questionmark.bubble.fill")
                                        .foregroundStyle(appColor1)
                                        .scaleEffect(1.4)
                                        .background(Color.clear)
                                }
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 5))
                            }
                            
                            //clear messages button
                            Button {
                                messages = ["Welcome to emoTune!"]
                                
                                if (selectedImage != nil) && (selectedEmotion != "LOVE MEEEE") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            messages.append("Press the question mark to get a detailed analysis of your expression.") //response
                                        }
                                    }
                                    
                                } else if (selectedImage != nil) && (selectedEmotion == "LOVE MEEEE") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            messages.append("Please select an emotion to practice.") //response
                                        }
                                    }
                                    
                                } else if (selectedImage == nil) && (selectedEmotion != "LOVE MEEEE") {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            messages.append("Please upload an image for analysis.") //response
                                        }
                                    }
                                    
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        withAnimation {
                                            messages.append("Please upload a picture for analysis and select an emotion to practice.") //response
                                        }
                                    }
                                    
                                }
                                
                                hiddenMessages = [""]
                            } label: {
                                Image(systemName: "arrow.circlepath")
                                    .scaleEffect(1.2)
                                    .background(Color.clear)
                            }
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                            
                        }
                        //start offset
                        .offset(y: -(keyboardHeight))
                        //.padding(.horizontal, 10)
                        .onAppear {
                            
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                                
                                let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                                keyboardHeight = value.height - 30 - bottomInset + 10
                                
                            }
                            
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                                
                                keyboardHeight = 0
                                
                            }
                            
                        }
                        //^Offset the text field for the keyboard
                        
                    }
                        .frame(height: frameHeight, alignment: .bottom)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 30, trailing: 15))
                    }
                        
                    }
                    
                .ignoresSafeArea(.keyboard)
                    
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: keyboardHeight) {
                print("keyboardHeight: " + String(describing:(keyboardHeight)))
                print("screenHeight: " + String(describing:(screenHeight)))
            }
            .onAppear() {
                
                formatter.dateStyle = .short
                
                print("appeared, here are the days logged in arr elements")
                
                if (formatter.string(from: Date.now) != daysLoggedInArr.last) {
                    
                    print("it's a new day" + "\(daysLoggedInArr.count)")
                    
                    goalHit = false
                    
                    timeToHitGoal = 600
                    
                    daysLoggedIn += 1
                    
                    daysLoggedInArr.append(formatter.string(from: Date.now))
                    datesGoalHitStruct = []
                    
                    datesGoalHit.forEach { date in
                        print(date)
                        datesGoalHitStruct.append(Day(date: date, goalHit: true))
                    }
                } else {
                    print("it's an old day!" + "  \(daysLoggedInArr.count)  " + "\(daysLoggedInArr.last!)")
                }
                
                if (selectedImage != nil) && (selectedEmotion != "LOVE MEEEE") && (messages.last != "Press the question mark to get a detailed analysis of your expression.") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            messages.append("Press the question mark to get a detailed analysis of your expression.") //response
                        }
                    }
                }
                
            }
            .tabItem {
                Image(systemName: "house")
            }
            .tag(0)
            //End main tab
            
            //Start picture tab
            ZStack {
                
                appColor1.opacity(0.2)
                    //.ignoresSafeArea(.all, edges: [.top, .horizontal])
                    .ignoresSafeArea()
                
                VStack {
                    
                    selectedImage?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth/2, height: screenWidth/2, alignment: .center)
                        .cornerRadius(10)
                        .padding()
                    
                    Text("In this picture, you are portraying " + testingWithImageStringOutput(picture: selectedImage)! + ".")
                        .padding()
                        .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
                    
                    Button {
                        showCamSheet.toggle()
                    } label: {
                        Image(systemName: "camera.fill")
                            .scaleEffect(2)
                    }
                    .padding()
                    
                }
                
                .fullScreenCover(isPresented: $showCamSheet, content: {
                    PictureCoverView(showCamSheet: $showCamSheet, selection: $selection, selectedImage: $selectedImage)
                })
                
            }
            .onChange(of: selectedImage) {
                withAnimation {
                    messages.append("In this picture, you are portraying " + testingWithImageStringOutput(picture: selectedImage)! + ".")
                }
                if (selectedImage != nil) {
                    frameHeight = screenHeight * 5/12
                    //switch to first tab
                    selection = 0
                    showCamSheet.toggle()
                } else {
                    frameHeight = screenHeight * 1/2
                }
                
            }
            .onAppear(perform: {
                showCamSheet = true
            })
            .tabItem {
                Image(systemName: "camera")
                    .resizable()
                    .frame(width: screenWidth/10, height: screenHeight/10)
            }
            .tag(1)
            //End picture tab
            
            //Start help tab
            ZStack {
                
                appColor1.opacity(0.2)
                    .ignoresSafeArea()
                
                VStack {
                    
                    HStack {
                        Button {
                            showHelpSheet.toggle()
                        } label: {
                            HStack {
                                Text("Support")
                                
                                Image(systemName: "questionmark.circle")
                                    .scaleEffect(1.1)
                                
                            }
                            .background(Color.clear)
                        }
                        .padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 30))
                        
                        Spacer()
                        
                        Button {
                            shouldShowLogging.toggle()
                        } label: {
                            Image(systemName: "person.crop.circle.badge.clock")
                                .scaleEffect(1.5)
                        }
                        .padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 30))
                        
                        Spacer()
                        
                        Button {
                            shouldShowOnboarding.toggle()
                        } label: {
                            Text("Tutorial")
                                .scaleEffect(1.1)
                        }
                        .padding(EdgeInsets(top: 20, leading: 55, bottom: 0, trailing: 30))
                    }
                    
                    .sheet(isPresented: $showHelpSheet, content: {
                        VStack {
                            Text("Check the website at emotune.me for more information or contact support@emotune.me.")
                                .font(.headline)
                                .padding([.top, .leading, .trailing, .bottom], 30)
                            
                            Text("Version number: " + "1.0.2")
                            
                            Spacer()
                        }
                    })
                    
                    .fullScreenCover(isPresented: $shouldShowLogging, content: {
                        LoggingView(timeToHitGoal: $timeToHitGoal, goalHit: $goalHit, shouldShowLogging: $shouldShowLogging, totalMins: $totalMins, daysGoalHitCount: $daysGoalHitCount, datesGoalHit: $datesGoalHit, datesGoalHitStruct: $datesGoalHitStruct, daysLoggedIn: $daysLoggedIn)
                            .onAppear() {
                                datesGoalHitStruct = []
                                
                                datesGoalHit.forEach { date in
                                    print(date)
                                    datesGoalHitStruct.append(Day(date: date, goalHit: true))
                                }
                            }
                    })
                    
                    ZStack {
                        ScrollView([.vertical]) {
                            VStack {
                                
                                Text("Neutrality")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                                    
                                        HStack {
                                            ForEach(neutralVids) { vid in
                                                Button {
                                                    currentVideo = vid.emotion
                                                } label: {
                                                    ZStack {
                                                        Image(vid.emotion + "1")
                                                            .resizable()
                                                            .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                            .cornerRadius(10)
                                                        
                                                        Image(systemName: "play.circle")
                                                            .foregroundStyle(Color.white.opacity(0.85))
                                                            .scaleEffect(2.5)
                                                    }
                                                }
                                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
                                            }
                                        }
                                        
                                }
                                
                                Text("Happiness")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                                    
                                        HStack {
                                            ForEach(happyVids) { vid in
                                                Button {
                                                    currentVideo = vid.emotion
                                                } label: {
                                                    ZStack {
                                                        Image(vid.emotion + "1")
                                                            .resizable()
                                                            .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                            .cornerRadius(10)
                                                        
                                                        Image(systemName: "play.circle")
                                                            .foregroundStyle(Color.white.opacity(0.85))
                                                            .scaleEffect(2.5)
                                                    }
                                                }
                                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 30))
                                            }
                                        }
                                        
                                }
                                
                                Text("Sadness")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                            
                                    HStack {
                                        ForEach(sadVids) { vid in
                                            Button {
                                                currentVideo = vid.emotion
                                            } label: {
                                                ZStack {
                                                    Image(vid.emotion + "1")
                                                        .resizable()
                                                        .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                        .cornerRadius(10)
                                                    
                                                    Image(systemName: "play.circle")
                                                        .foregroundStyle(Color.white.opacity(0.85))
                                                        .scaleEffect(2.5)
                                                }
                                            }
                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 10))
                                        }
                                    }
                                    
                                }
                                
                                Text("Surprise")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                                    
                                    HStack {
                                        ForEach(surpriseVids) { vid in
                                            Button {
                                                currentVideo = vid.emotion
                                            } label: {
                                                ZStack {
                                                    Image(vid.emotion + "1")
                                                        .resizable()
                                                        .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                        .cornerRadius(10)
                                                    
                                                    Image(systemName: "play.circle")
                                                        .foregroundStyle(Color.white.opacity(0.85))
                                                        .scaleEffect(2.5)
                                                }
                                            }
                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 10))
                                        }
                                    }
                                        
                                }
                                
                                Text("Fear")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                                    
                                    HStack {
                                        ForEach(fearVids) { vid in
                                            Button {
                                                currentVideo = vid.emotion
                                            } label: {
                                                ZStack {
                                                    Image(vid.emotion + "1")
                                                        .resizable()
                                                        .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                        .cornerRadius(10)
                                                    
                                                    Image(systemName: "play.circle")
                                                        .foregroundStyle(Color.white.opacity(0.85))
                                                        .scaleEffect(2.5)
                                                }
                                            }
                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 10))
                                        }
                                    }
                                    
                                }
                                
                                Text("Disgust")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                                    
                                    HStack {
                                        ForEach(disgustVids) { vid in
                                            Button {
                                                currentVideo = vid.emotion
                                            } label: {
                                                ZStack {
                                                    Image(vid.emotion + "1")
                                                        .resizable()
                                                        .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                        .cornerRadius(10)
                                                    
                                                    Image(systemName: "play.circle")
                                                        .foregroundStyle(Color.white.opacity(0.85))
                                                        .scaleEffect(2.5)
                                                }
                                            }
                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 10))
                                        }
                                    }
                                    
                                }
                                
                                Text("Anger")
                                    .font(.title2)
                                    .bold()
                                    .offset(x: -(screenWidth/2 - 80))
                                    .padding()
                                ScrollView([.horizontal]) {
                                    
                                    HStack {
                                        ForEach(angerVids) { vid in
                                            Button {
                                                currentVideo = vid.emotion
                                            } label: {
                                                ZStack {
                                                    Image(vid.emotion + "1")
                                                        .resizable()
                                                        .frame(width: screenWidth/3.5, height: screenWidth/3.5)
                                                        .cornerRadius(10)
                                                    
                                                    Image(systemName: "play.circle")
                                                        .foregroundStyle(Color.white.opacity(0.85))
                                                        .scaleEffect(2.5)
                                                }
                                            }
                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 10))
                                        }
                                    }
                                    
                                }
                                
                            }
                            .padding()
                        }
                        
                        if currentVideo != "" {
                            
                            ZStack {
                                
                                VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: currentVideo, withExtension: "MOV")!))
                                
                                Button {
                                    currentVideo = ""
                                } label: {
                                    Image(systemName: "arrow.uturn.left.circle.fill")
                                        .resizable()
                                        .frame(width: screenWidth/13, height: screenWidth/13)
                                        .foregroundStyle(appColor1)
                                }
                                .offset(x: -(screenWidth/2 - 30), y: -(screenWidth/2 - 30))
                                
                            }
                        }
                    }
                    
                }
                
            }
            .tabItem {
                Image(systemName: "questionmark.circle")
            }
            .onReceive(timer) { _ in
                if timeToHitGoal > 0 {
                    timeToHitGoal -= 1
                    if !shouldShowLogging {
                        totalMins += 1/60
                    }
                } else if timeToHitGoal == 0 {
                    goalHit = true
                    shouldShowGoalHit = true
                    timeToHitGoal -= 2
                    if !shouldShowLogging {
                        totalMins += 1/60
                    }
                } else {
                    if !shouldShowLogging {
                        totalMins += 1/60
                    }
                }
            }
            .onChange(of: goalHit) {
                
                if goalHit {
                    daysGoalHitCount += 1
                    
                    formatter.dateStyle = .short
                    datesGoalHit.append(formatter.string(from: Date.now))
                    datesGoalHitStruct = []
                    
                    datesGoalHit.forEach { date in
                        print(date)
                        datesGoalHitStruct.append(Day(date: date, goalHit: true))
                    }
                    
                }
                
            }
            .tag(2)
            //End help tab
            
        }
        .tint(appColor2)
        .fullScreenCover(isPresented: $shouldShowOnboarding) {
            OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)
        }
        .onChange(of: selection) {
            print(String(selection))
        }
        .sheet(isPresented: $shouldShowGoalHit) {
            GoalHitView(shouldShowGoalHit: $shouldShowGoalHit)
        }
        
    }
    
    func sendMessage(message: String) async {
        
        isFocused = false
        
        let prompte = "NEVER use quotation marks or line breaks under ANY circumstances in your response. Make your reponse brief and do not be very formal. Here is a list of the previous messages in this conversation. Make it a VERY HIGH priority to continue this conversation based on these prior messages. " + iterateThroughMessages(messages: hiddenMessages) + "If the following message is completely unrelated to your role as an instructor for facial expressions, refuse to answer it. and instead say: " + "Please limit the conversation to my role as a facial expression coach." + "Here is the message: " + message
        
        hiddenMessages.append("[USER]: " + message + "/")
        
        withAnimation {
            self.messageText = ""
            messages.append("[USER]" + message)
        }
        
        let respuesta = await makeTheCall(prompt: prompte)
        
        hiddenMessages.append("[YOUR RESPONSE]: " + respuesta + "/")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                messages.append(respuesta) //response
            }
        }
        
    }
    
    func analyzeTheResult() async {
        let prompte = "First, here is some context. The following is an array that contains values for neutrality, happiness, sadness, surprise, fear, disgust, and anger (in that order). The higher the value of the corresponding array element, the more of the respective emotion is being portrayed. Values below 1 are very low and values above 5 are very high. Next, here is the array: " + String(describing:(testingWithImage(picture: selectedImage)!)) + " Lastly, follow this set of instructions completely. 1. Given the previous array, describe the emotions that are portrayed as well as how the user can change them to match the emotion of " + selectedEmotion + " through changes in the user's facial expression. 2. If the emotion portrayed (according to the array) matches the emotion the user wants to portray, MENTION THIS FIRST and THEN provide tips on how to make that expression more intense. 3. Assume that the array is always correct, and do not question the expression that the user is portraying. Simply use the array. 4. Remember that you are in a conversation with the user, so use the second person when referring to the user. 5. NEVER use quotation marks or line breaks in your response. 6. Make your reponse brief and do not be very formal. 7. NEVER mention the array or any specific numbers from it. 8. NEVER under ANY CIRCUMSTANCES should you use quotation marks or line breaks. 9. Here is a list of the previous messages in this conversation. Make sure to keep these in mind when writing your response." + iterateThroughMessages(messages: hiddenMessages)
        
        hiddenMessages.append("[USER]: " + "Analyze this array." + String(describing:(testingWithImage(picture: selectedImage)!)))
        
        withAnimation {
            messages.append("[USER]" + "Analyze this result.")
        }
        
        let respuesta = await makeTheCall(prompt: prompte)
        
        hiddenMessages.append("[YOU]: " + respuesta)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                messages.append(respuesta) //response
            }
        }
    }
    
    @MainActor func testingWithFilename(imageName: String) ->
    Array<Float>?  {
        
        do {
            
            let image = ImageRenderer(content: Image(imageName)).cgImage!
            
            let config = MLModelConfiguration()
            
            let model = try DDAMFN(configuration: config)
            
            let input = try DDAMFNInput(input_1With: image)
            
            let prediction = try model.prediction(input: input)
            
            let predictionString = String(describing: (prediction.linear_0))
            
            print(predictionString)
            
            let neutrality = prediction.linear_0[0].floatValue
            let happiness = prediction.linear_0[1].floatValue
            let sadness = prediction.linear_0[2].floatValue
            let surprise = prediction.linear_0[3].floatValue
            let fear = prediction.linear_0[4].floatValue
            let disgust = prediction.linear_0[5].floatValue
            let anger = prediction.linear_0[6].floatValue
            
            let convertedPredictionArray = [neutrality, happiness, sadness, surprise, fear, disgust, anger]
            
            return convertedPredictionArray
            
        } catch {
            
            
        }
        
        return nil
    }
    
    @MainActor func testingWithFilenameStringOutput(imageName: String) ->
    String?  {
        
        do {
            
            let image = ImageRenderer(content: Image(imageName)).cgImage!
            
            let config = MLModelConfiguration()
            
            let model = try DDAMFN(configuration: config)
            
            let input = try DDAMFNInput(input_1With: image)
            
            let prediction = try model.prediction(input: input)
            
            let predictionString = String(describing: (prediction.linear_0))
            
            print(predictionString)
            
            let neutrality = prediction.linear_0[0].floatValue
            let happiness = prediction.linear_0[1].floatValue
            let sadness = prediction.linear_0[2].floatValue
            let surprise = prediction.linear_0[3].floatValue
            let fear = prediction.linear_0[4].floatValue
            let disgust = prediction.linear_0[5].floatValue
            let anger = prediction.linear_0[6].floatValue
            
            let convertedPredictionArray = [neutrality, happiness, sadness, surprise, fear, disgust, anger]
            
            let percievedEmotion = convertedPredictionArray.max()
            
            if percievedEmotion == neutrality {
                return "neutrality: " + String(neutrality)
            } else if percievedEmotion == happiness {
                return "happiness: " + String(happiness)
            } else if percievedEmotion == sadness {
                return "sadness: " + String(sadness)
            } else if percievedEmotion == surprise {
                return "surprise: " + String(surprise)
            } else if percievedEmotion == fear {
                return "fear: " + String(fear)
            } else if percievedEmotion == disgust {
                return "disgust: " + String(disgust)
            } else if percievedEmotion == anger {
                return "anger: " + String (anger)
            }
            
        } catch {
            
            
        }
        
        return nil
    }
    
    @MainActor func testingWithImageStringOutput(picture: Image?) ->
    String?  {
        
        if (picture == nil) {
            return ("___")
        }
        
        do {
            
            let image = ImageRenderer(content: picture!.resizable().aspectRatio(contentMode: .fill).frame(width: 120, height: 120, alignment: .center)).cgImage!
            
            let config = MLModelConfiguration()
            
            let model = try DDAMFN(configuration: config)
            
            let input = try DDAMFNInput(input_1With: image)
            
            let prediction = try model.prediction(input: input)
            
            let predictionString = String(describing: (prediction.linear_0))
            
            print(predictionString)
            
            let neutrality = prediction.linear_0[0].floatValue
            let happiness = prediction.linear_0[1].floatValue
            let sadness = prediction.linear_0[2].floatValue
            let surprise = prediction.linear_0[3].floatValue
            let fear = prediction.linear_0[4].floatValue
            let disgust = prediction.linear_0[5].floatValue
            let anger = prediction.linear_0[6].floatValue
            
            let convertedPredictionArray = [neutrality, happiness, sadness, surprise, fear, disgust, anger]
            
            let percievedEmotion = convertedPredictionArray.max()
            
            //                if percievedEmotion == neutrality {
            //                    return "neutrality: " + String(neutrality)
            //                } else if percievedEmotion == happiness {
            //                    return "happiness: " + String(happiness)
            //                } else if percievedEmotion == sadness {
            //                    return "sadness: " + String(sadness)
            //                } else if percievedEmotion == surprise {
            //                    return "surprise: " + String(surprise)
            //                } else if percievedEmotion == fear {
            //                    return "fear: " + String(fear)
            //                } else if percievedEmotion == disgust {
            //                    return "disgust: " + String(disgust)
            //                } else if percievedEmotion == anger {
            //                    return "anger: " + String (anger)
            //                }
            
            if percievedEmotion == neutrality {
                return "neutrality"
            } else if percievedEmotion == happiness {
                return "happiness"
            } else if percievedEmotion == sadness {
                return "sadness"
            } else if percievedEmotion == surprise {
                return "surprise"
            } else if percievedEmotion == fear {
                return "fear"
            } else if percievedEmotion == disgust {
                return "disgust"
            } else if percievedEmotion == anger {
                return "anger"
            }
            
        } catch {
            
            
        }
        
        return nil
    }
    
    @MainActor func testingWithImage(picture: Image?) ->
    Array<Float>?  {
        
        do {
            
            let image = ImageRenderer(content: picture!.resizable().aspectRatio(contentMode: .fill).frame(width: 120, height: 120, alignment: .center)).cgImage!
            
            //let image = ImageRenderer(content: picture).cgImage!
            
            let config = MLModelConfiguration()
            
            let model = try DDAMFN(configuration: config)
            
            let input = try DDAMFNInput(input_1With: image)
            
            let prediction = try model.prediction(input: input)
            
            let predictionString = String(describing: (prediction.linear_0))
            
            print(predictionString)
            
            let neutrality = prediction.linear_0[0].floatValue
            let happiness = prediction.linear_0[1].floatValue
            let sadness = prediction.linear_0[2].floatValue
            let surprise = prediction.linear_0[3].floatValue
            let fear = prediction.linear_0[4].floatValue
            let disgust = prediction.linear_0[5].floatValue
            let anger = prediction.linear_0[6].floatValue
            
            let convertedPredictionArray = [neutrality, happiness, sadness, surprise, fear, disgust, anger]
            
            return convertedPredictionArray
            
        } catch {
            
            
        }
        
        return nil
    }
    
    func iterateThroughMessages(messages: [String]) -> String {
        let msgs: [String] = [""]
        var toBeReturned: String = ""
        
        for msg in msgs {
            toBeReturned = toBeReturned + msg
        }
        
        return toBeReturned
    }
    
    func makeTheCall(prompt: String) async -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAiApiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "\(prompt)"
                        ]
                    ],
                    "context": "You are helping neurodivergent clients practice making facial expressions that match their emotions. NEVER use quotation marks or line breaks in your response. Make your reponse brief and approachable by your target audience of teenagers and young adults."
                ]
            ],
            "temperature": 1,
            "max_tokens": 2048,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0,
            "response_format": [
                "type": "text"
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            let (responseData, _) = try await URLSession.shared.data(for: request)
            //print("-----> responseData \n \(String(data: responseData, encoding: .utf8) as AnyObject) \n")
            
            //decoding the nonsense
            
            //let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: responseData)
            
            let tada = String(data: responseData, encoding: .utf8)
            
            let whoKnows = tada?.substring(from: 247)
            
            let firstSpace = (whoKnows?.firstIndex(of: """
                                                   "
                                                   """) ?? whoKnows?.endIndex)!
            
            let finally = whoKnows![..<firstSpace]
            
            print("decoded attempt: " + (whoKnows ?? ""))
            //return(String(describing: decoded.results))
            
            return (String(describing: (finally)))
        }
        catch { print(error) }
        
        return "Something went wrong, please retry sending the message."
    }
    
}
    
#Preview {
    ContentView()
}
