import SwiftUI

struct Topic: Identifiable {
    let id: String
    let name: String
    var isSelected: Bool
}

struct HomeView: View {
    @ObservedObject var viewModel: CallNewsApi
    @State private var topics: [Topic] = [
        Topic(id: "entertainment", name: "Entertainment", isSelected: false),
        Topic(id: "technology", name: "Technology", isSelected: false),
        Topic(id: "business", name: "Business", isSelected: false),
        Topic(id: "sports", name: "Sports", isSelected: false),
        Topic(id: "health", name: "Health", isSelected: false),
        Topic(id: "science", name: "Science", isSelected: false),
    ]
    
    @State private var showingFavorites = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select Topics")
                    .font(.title)
                    .padding(.bottom)
                
                // Grid of topics with box around it
                VStack {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach($topics) { $topic in
                            Button(action: {
                                withAnimation {
                                    topic.isSelected.toggle()
                                }
                            }) {
                                Text(topic.name)
                                    .fontWeight(.medium)
                                    .foregroundColor(topic.isSelected ? .white : .primary)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(topic.isSelected ? Color.blue : Color(UIColor.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: topic.isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 5)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
                
                // View Favorites button with improved UI
                Button("View Favorites") {
                    showingFavorites.toggle()
                }
                .sheet(isPresented: $showingFavorites) {
                    FavoritesView(viewModel: viewModel)
                }
                .buttonStyle(PrimaryButtonStyle())
                
                // Return to News button with improved UI
                Button(action: {
                    withAnimation {
                            viewModel.showHomeView = false
                    }
                }) {
                    Label("Return to News", systemImage: "newspaper.fill").colorInvert()
                }
                .buttonStyle(PrimaryButtonStyle(background: .blue))
            }
            .padding()
            .navigationTitle("Home")
            .transition(.opacity)
        }
    }
}

// Primary button style used for both buttons in the view
struct PrimaryButtonStyle: ButtonStyle {
    var background: Color = .white
    var foreground: Color = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(background)
            .foregroundColor(foreground)
            .cornerRadius(10)
            .shadow(radius: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
