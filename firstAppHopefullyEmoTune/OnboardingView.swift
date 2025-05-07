//
//  OnboardingView.swift
//  firstAppHopefullyEmoTune
//
//  Created by Admin on 1/16/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var shouldShowOnboarding: Bool
    @State var selectedEmotion: String = ""
    @State var messageText: String = ""
    @FocusState var isFocused: Bool
    
    var body: some View {
        TabView {
            //intro
            VStack {
                Text("Welcome to emoTune!")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                
                
                Text("emoTune, short for emotion tuner, is a tool to help people practice communicating through facial expressions. AI-powered image analysis and a personal chat assistant work in tandem so you know exactly how to show the emotions you want to portray.")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                
                Text("Swipe left to continue")
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
            
            //step 1, select the emotion to practice
            VStack {
                Text("Step 1: Select an emotion to practice")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                HStack {
                    if (selectedEmotion != "") {
                        HStack {
                            
                            Text("You are trying to show: ")
                            
                            Menu {
                                Button ("Neutrality 😶") {
                                    selectedEmotion = "Neutrality 😶"
                                }
                                Button ("Happiness 😊") {
                                    selectedEmotion = "Happiness 😊"
                                    
                                }
                                Button ("Sadness ☹️") {
                                    selectedEmotion = "Sadness ☹️"
                                }
                                Button ("Surprise 😯") {
                                    selectedEmotion = "Surprise 😯"
                                    
                                }
                                Button ("Fear 😣") {
                                    selectedEmotion = "Fear 😣"
                                    
                                }
                                Button ("Disgust 😖") {
                                    selectedEmotion = "Disgust 😖"
                                    
                                }
                                Button ("Anger 😠") {
                                    selectedEmotion = "Anger 😠"
                                    
                                }
                                
                            } label: {
                                Text(selectedEmotion)
                            }
                        }
                        
                    } else {
                        Menu {
                            Button ("Neutrality 😶") {
                                selectedEmotion = "Neutrality 😶"
                            }
                            Button ("Happiness 😊") {
                                selectedEmotion = "Happiness 😊"
                                
                            }
                            Button ("Sadness ☹️") {
                                selectedEmotion = "Sadness ☹️"
                            }
                            Button ("Surprise 😯") {
                                selectedEmotion = "Surprise 😯"
                                
                            }
                            Button ("Fear 😣") {
                                selectedEmotion = "Fear 😣"
                                
                            }
                            Button ("Disgust 😖") {
                                selectedEmotion = "Disgust 😖"
                                
                            }
                            Button ("Anger 😠") {
                                selectedEmotion = "Anger 😠"
                                
                            }
                            
                        } label: {
                            Text("Try it out here!")
                        }
                        
                    }
                }
                .padding(.vertical, 25)
                
                Text("Choose the emotion you want to work on portraying. emoTune can help you practice seven emotions: neutrality, happiness, sadness, surprise, fear, disgust, and anger. These are the seven universal emotions as recognized by psychologists.")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
            }
            
            //step 2, upload a picture of yourself
            VStack {
                Text("Step 2: Upload a picture of yourself")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                HStack {
                    Image(systemName: "camera")
                        .scaleEffect(3.5)
                        .padding(.horizontal, 30)
                    
                    Image(systemName: "photo")
                        .scaleEffect(3.5)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 25)
                
                Text("Upload a picture of yourself using the camera or your photo library.")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                
                Text("These pictures are not recorded or kept by emoTune in any way.")
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
            
            //step 3, get an analysis
            VStack {
                Text("Step 3: Get an analysis of the emotions in the picture")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                HStack {
                    Image(systemName: "questionmark.bubble.fill")
                        .scaleEffect(3.5)
                        .padding(.horizontal, 30)
                        .padding()
                }
                
                ZStack {
                    
                    HStack {
                        TextField("Ask a question here", text: $messageText)
                            .padding()
                            .background(Color.white)//.opacity(0.1))
                            .foregroundStyle(Color.black)
                            .cornerRadius(10)
                            .focused($isFocused)
                            .onSubmit {
                                messageText = ""
                            }
                        
                        //analyze the image button
                        Button {
                            print("hello!")
                        } label: {
                            Image(systemName: "questionmark.bubble.fill")
                                .scaleEffect(1.4)
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 5))
                        
                        //clear messages button
                        Button {
                            print("goodbye!")
                        } label: {
                            Image(systemName: "arrow.circlepath")
                                .scaleEffect(1.2)
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    }
                    .padding(EdgeInsets(top: 45, leading: 25, bottom: 5, trailing: 25))
                    
                }
                
                Text("After you have selected an emotion to practice AND you have uploaded a picture, press this button to request an analysis of your facial expression. Your chat assistant will tell you exactly how you can adjust your face to show any of the seven primary emotions.")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                
                
            }
            .onTapGesture {
                isFocused = false
            }
            .padding(.vertical, 25)
            
            //help tab
            VStack {
                Text("Help")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                HStack {
                    Image(systemName: "questionmark.circle")
                        .scaleEffect(3.5)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 25)
                Text("If you are not sure how to follow the advice from your chat assistant, there are tutorial videos for all individual feature changes that you will need. Simply tap on the help tab and choose the emotion whose expression you want to view examples for.")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
            }
            
            //logging tab
            VStack {
                Text("Logging your practice times")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                HStack {
                    Image(systemName: "person.crop.circle.badge.clock")
                        .scaleEffect(3.5)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 25)
                Text("You can track how much time you've put into practicing with emoTune by using the logging button in the help tab. The commitment goal is automatically set for 10 minutes per day of usage.")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
            }
            
            VStack {
                
                Text("Ready?")
                    .font(.largeTitle)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .multilineTextAlignment(.center)
                
                Button {
                    shouldShowOnboarding.toggle()
                } label: {
                    Text("Let's go!")
                        .font(.title)
                }
                .padding()
                
            }
            
        }
        .tabViewStyle(.page)
        
    }
    
}


#Preview {
    OnboardingView(shouldShowOnboarding: .constant(true))
}
