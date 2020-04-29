//
//  FirstStartUI.swift
//  HamMessenger
//
//  Created by Nicolas Bachschwell on 27.04.20.
//  Copyright © 2020 NBSgamesAT. All rights reserved.
//

import SwiftUI

struct FirstStartUI: View {
  @State private var callsign: String = ""
  @State private var name: String = ""
  @State private var qthLocator: String = ""
  @State private var location: String = ""
  @State private var ip: String = ""
  var body: some View {
    HStack{
      Spacer(minLength: 16)
      VStack{
        VStack{
          Text("Welcome").font(.system(size: 30)).bold()
          Text("to the HamMessenger, please enter your information to begin").multilineTextAlignment(.center)
        }
        Spacer()
        VStack {
          Text("Callsign").font(.system(size: 27))
          TextField("Callsign", text: $callsign).font(.system(size: 27)).border(Color.gray, width: 5).cornerRadius(10)
          Text("Name").font(.system(size: 27))
          TextField("Name", text: $name).font(.system(size: 27)).border(Color.gray, width: 5).cornerRadius(10)
          Text("QTH Locator").font(.system(size: 27))
          TextField("QTH Locator", text: $qthLocator).font(.system(size: 27)).border(Color.gray, width: 5).cornerRadius(10)
          Text("Location").font(.system(size: 27))
          TextField("Location", text: $location).font(.system(size: 27)).border(Color.gray, width: 5).cornerRadius(10)
          Text("IP Address").font(.system(size: 27))
          TextField("IP Address", text: $ip).font(.system(size: 27)).border(Color.gray, width: 5).cornerRadius(10)
        }
        Spacer()
        Button(action: {
        }) {
          HStack{
            Spacer()
            Text("Save").font(.system(size: 30)).padding(4)
            Spacer()
          }
        }
      }
      Spacer(minLength: 16)
    }
  }
}

private class KeyboardResponder {
  init(){
  }
}

struct FirstStartUI_Previews: PreviewProvider {
    static var previews: some View {
        FirstStartUI()
    }
}
