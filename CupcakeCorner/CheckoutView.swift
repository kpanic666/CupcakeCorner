//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Andrei Korikov on 22.08.2021.
//

import SwiftUI

struct CheckoutView: View {
  @ObservedObject var order: Order
  @State private var confirmationMessage = ""
  @State private var showingConfirmation = false
  
    var body: some View {
      GeometryReader { geo in
        ScrollView {
          VStack {
            Image("cupcakes")
              .resizable()
              .scaledToFit()
              .frame(width: geo.size.width)
            
            Text("Your total is $\(order.cost, specifier: "%.2f")")
              .font(.title)
            
            Button("Place Order") {
              placeOrder()
            }
            .padding()
          }
        }
      }
      .navigationBarTitle("Check out", displayMode: .inline)
      .alert(isPresented: $showingConfirmation, content: {
        Alert(title: Text("Thank you"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
      })
    }
  
  func placeOrder() {
    guard let encoded = try? JSONEncoder().encode(order) else {
      print("Failed to encode order")
      return
    }
    
    let url = URL(string: "https://reqres.in/api/cupcakes")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = encoded
    
    URLSession.shared.dataTask(with: request) {
      data, response, error in
      
      guard let data = data else {
        confirmationMessage = "No data in response: \(error?.localizedDescription ?? "Unknown error")."
        showingConfirmation = true
        return
      }
      
      if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
        confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
        showingConfirmation = true
      } else {
        print("Invalid response from server")
      }
    }.resume()
  }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
