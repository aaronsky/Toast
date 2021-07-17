# Toast 🍞

A simple weekend project for rendering toast-style elements in the current frame in SwiftUI. This is not a recommended iOS design pattern and should only be used when you need some way to epehemerally and unobtrusively inform the user of something. **It is also not production ready and comes with no warranty.**

<div align="center">
  <img src="https://user-images.githubusercontent.com/10502938/126051149-72224223-0f48-4a69-8e88-6e0cee2e7b1e.gif" width="25%" height="25%" />
</div>

## Usage

### With a flag

```swift
import SwiftUI
import Toast

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
import Toast

struct ContentView: View {
    enum Item: String, CaseIterable, Identifiable {
        case misty
        case brock
        case tracy
        case may
        case max
        case dawn

        var id: Self {
            self
        }
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

## License

[The MIT License](./LICENSE) © 2021 Aaron Sky
