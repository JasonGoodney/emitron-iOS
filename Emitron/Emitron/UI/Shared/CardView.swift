/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

enum CardViewType: Hashable {
  case `default`
  case bookmark
}

enum ImageType: Hashable {
  case asset(UIImage)
  case url(URL)
}

// Shuold be data model independent, so that we can transform any type of data into the cardViewModel data
struct CardViewModel: Hashable {
  let title: String
  let subtitle: String
  let description: String
  let imageType: ImageType
  let footnote: String
  let type: CardViewType
  let progress: CGFloat
}

// Transform data
extension CardViewModel {
  static func transform(_ content: ContentDetailModel, cardViewType: CardViewType) -> CardViewModel? {
    let subtitle = content.domains.map { $0.name }.joined(separator: ", ")
    let progress = CGFloat(content.progression?.percentComplete ?? 0)
    
    var imageType: ImageType
    
    if let imageURL = content.cardArtworkURL {
      imageType = ImageType.url(imageURL)
    } else {
      imageType = ImageType.asset(#imageLiteral(resourceName: "loading"))
    }
    
    let cardModel = CardViewModel(title: content.name, subtitle: subtitle, description: content.description, imageType: imageType, footnote: content.dateAndTimeString, type: cardViewType, progress: progress)
    
    return cardModel
  }
}

struct CardView: View {
  
  @State private var image: UIImage = #imageLiteral(resourceName: "loading")
  private var model: CardViewModel
  
  init(model: CardViewModel) {
    self.model = model
  }

  //TODO - Multiline Text: There are some issues with giving views frames that result in .lineLimit(nil) not respecting the command, and
  // results in truncating the text
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 5) {
            
            Text(model.title)
              .font(.uiTitle4)
              .lineLimit(nil)
            
            Text(model.subtitle)
              .font(.uiCaption)
              .lineLimit(nil)
              .foregroundColor(.battleshipGrey)
          }
          
          Spacer()
                    
          Image(uiImage: image)
            .resizable()
            .frame(width: 60, height: 60)
            .onAppear(perform: loadImage)
            .transition(.opacity)
            .cornerRadius(6)
        }
        
        Text(model.description)
          .font(.uiCaption)
          .lineLimit(5)
          .foregroundColor(.battleshipGrey)
        
        Spacer()
        
        HStack {
          Text(model.footnote)
            .font(.uiCaption)
            .lineLimit(1)
            .foregroundColor(.battleshipGrey)
          
          Spacer()
          
          Image("downloadInactive")
            .resizable()
            .frame(width: 19, height: 19)
            .onTapGesture {
              self.download()
            }
        }
      }
      .padding([.leading, .trailing, .top, .bottom], 15)
      .frame(minHeight: 184)
      
      Spacer()
      
      ProgressBarView(progress: model.progress)
    }
    .frame(minWidth: 339, minHeight: 195)
    .background(Color.white)
    .cornerRadius(6)
    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 2)
  }
  
  private func download() {
    print("Download button pressed.")
  }
  
  private func loadImage() {
    //TODO: Will be uising Kingfisher for this, for performant caching purposes, but right now just importing the library
    // is causing this file to not compile
    switch model.imageType {
    case .asset(let img):
      image = img
    case .url(let url):
      DispatchQueue.global().async {
        let data = try? Data(contentsOf: url)
        if let data = data,
          let img = UIImage(data: data) {
          DispatchQueue.main.async {
            self.image = img
          }
        }
      }
    }
  }
}

#if DEBUG
struct CardView_Previews: PreviewProvider {
  static var previews: some View {
    let cardModel = CardViewModel.transform(ContentDetailModel.test, cardViewType: .default)!
    return CardView(model: cardModel)
  }
}
#endif
