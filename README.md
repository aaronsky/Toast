# Toast

A simple weekend project for rendering toast-style elements in the current frame in SwiftUI. **It is not production ready** and comes with no warranty. 

## Usage

### With a flag

```swift
import SwiftUI

struct ContentView: View {
  @State private var showToast = false

  var body: some View {
    Button("Show a toast!") {
      showToast = true
    }.toast(isPresented: $showToast) {
      Label("I am a toast. 🍞", systemImage: "ladybug")
    }
  }
}
```

### With an Identifiable item

```swift

import SwiftUI

struct ContentView: View {
  enum Item: String, CaseIterable, Identifiable {
    case misty
    case brock
    case tracy
    case may
    case max
    case dawn
  }

  @State private var item: Item?

  var body: some View {
    List(Item.allCases) { item in
      Button(item.rawValue) {
        withAnimation(.easeOut) {
            self.item = item
        }
      }
    }
    .toast(item: $item) { item in
      Label(item.rawValue, systemImage: "ladybug")
    }
  }
}
```


Licensed under MIT
