//
//  PictureCoverView.swift
//  firstAppHopefullyEmoTune
//
//  Created by Admin on 1/11/25.
//

import SwiftUI
import PhotosUI

struct PictureCoverView: View {
    @Binding var showCamSheet: Bool
    @Binding var selection: Int
    @Binding var selectedImage: Image?
    @State var pickerItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    
    var body: some View {
        ZStack {
            //Cam view
            Color.black
                .ignoresSafeArea()
            
            HostedViewController(image: $selectedUIImage)
                .ignoresSafeArea()
            
            Rectangle()
                .stroke(Color.black, lineWidth: 10)
                .frame(width: UIScreen.main.bounds.width - 75, height: UIScreen.main.bounds.width - 75, alignment: .center)
            
            Text("Make sure that your face touches the edges of the box.")
                .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7))
                .foregroundStyle(Color.white)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .offset(y: -(UIScreen.main.bounds.width/2))
            
            VStack {
                HStack {
                    Button {
                        showCamSheet.toggle()
                        selection = 0
                    } label: {
                        Text("Cancel")
                            .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7))
                            .foregroundStyle(Color.white)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Image(systemName: "photo.fill")
                    .scaleEffect(3.0)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(Color.black.opacity(0.2))
            }
            .offset(x: -(UIScreen.main.bounds.width * 34/100), y: (UIScreen.main.bounds.height * 39/100))
            
                .onChange(of: pickerItem) {
                    Task {
                        let data = try? await (pickerItem?.loadTransferable(type: Data.self))
                        let image = UIImage(data: data!)
                        selectedImage = Image(uiImage: image!)
                        
                    }
                    
                }
                .onChange(of: selectedUIImage) {
                    if let selectedUIImage {
                        selectedImage = Image(uiImage: selectedUIImage)
                    }
                }

        }
    }
}

#Preview {
    PictureCoverView(showCamSheet: .constant(true), selection: .constant(1), selectedImage: .constant(Image(systemName: "questionmark.circle")))
}
