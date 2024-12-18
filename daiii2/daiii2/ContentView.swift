//
//  ContentView.swift
//  daiii2
//
//  Created by Silvia Lembo on 18/12/24.
//

import SwiftUI

// Splash Screen con animazione
struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scaleEffectValue = 0.5
    @State private var opacityValue = 0.5

    var body: some View {
        ZStack {
            // Background color light yellow
            Color(.green1) // Giallo chiaro
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                    .scaleEffect(scaleEffectValue)
                    .opacity(opacityValue)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            scaleEffectValue = 1.0
                            opacityValue = 1.0
                        }
                    }
                
                Text("Welcome to My Garden")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                    .padding(.top, 20)
                    // .shadow(radius: 10)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainTabView() // Naviga alla TabView dopo lo splash
        }
    }
}
import SwiftUI
import PhotosUI
import UserNotifications

// MARK: - Modello della Pianta
struct Plant: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var imageData: [Data]? // Cambiato a un array di dati per più immagini
    var wateringFrequency: Int // Frequenza in giorni
    var lastWateredDate: Date // Data ultima innaffiatura
}

// MARK: - ViewModel per Gestire i Dati
class GardenViewModel: ObservableObject {
    @Published var plants: [Plant] {
        didSet {
            savePlants()
        }
    }
    
    private let plantsKey = "plants_key"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: plantsKey),
           let decoded = try? JSONDecoder().decode([Plant].self, from: data) {
            self.plants = decoded
        } else {
            self.plants = []
        }
    }
    
    func addPlant(name: String, description: String, image: UIImage?, wateringFrequency: Int) {
        let imageData = image?.jpegData(compressionQuality: 0.8) // Converti l'immagine in dati
        let newPlant = Plant(name: name, description: description, imageData: imageData != nil ? [imageData!] : nil, wateringFrequency: wateringFrequency, lastWateredDate: Date())
        plants.append(newPlant)
        scheduleNotification(for: newPlant)
    }
    func addImageToPlant(plant: Plant, newImage: UIImage) {
        if let imageData = newImage.jpegData(compressionQuality: 0.8) {
            if let index = plants.firstIndex(where: { $0.id == plant.id }) {
                var updatedPlant = plants[index]
                if updatedPlant.imageData == nil {
                    updatedPlant.imageData = []
                }
                updatedPlant.imageData?.append(imageData) // Aggiungi la nuova immagine
                plants[index] = updatedPlant
                savePlants() // Salva immediatamente dopo aver aggiunto l'immagine
            }
        }
    }


    func deletePlant(at offsets: IndexSet) {
        plants.remove(atOffsets: offsets)
    }
    
    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(plants) {
            UserDefaults.standard.set(encoded, forKey: plantsKey)
        }
    }
    
    // MARK: - Notifiche Locali
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if success {
                print("Permessi concessi.")
            } else if let error = error {
                print("Errore nel richiedere permessi: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for plant: Plant) {
        let content = UNMutableNotificationContent()
        content.title = "È ora di innaffiare 🌿 \(plant.name)"
        content.body = "Ricordati di innaffiare \(plant.name) oggi!"
        content.sound = .default
        
        let triggerDate = Calendar.current.date(byAdding: .day, value: plant.wateringFrequency, to: plant.lastWateredDate) ?? Date()
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: plant.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore nella notifica: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Main View
struct GardenView: View {
    @StateObject private var viewModel = GardenViewModel()
    @State private var showAddPlantSheet = false
    @State private var selectedPlant: Plant?

    var body: some View {
        NavigationView {
            ZStack {
                // Background color light yellow
                Color(.green1)
                    .ignoresSafeArea()
                
                VStack {
                    if viewModel.plants.isEmpty {
                        Text("Crea il tuo giardino 🌱")
                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                            .italic()
                    } else {
                        List {
                            ForEach(viewModel.plants) { plant in
                                HStack {
                                    if let imageData = plant.imageData?.first,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .shadow(radius: 3)
                                    } else {
                                        Image(systemName: "leaf")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(plant.name)
                                            .font(.headline)
                                            .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                                        Text(plant.description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text("Prossima innaffiatura: \(plant.lastWateredDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    selectedPlant = plant
                                }
                            }
                            .onDelete(perform: viewModel.deletePlant)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden) // Nasconde lo sfondo grigio di default del List
                    }
                }
                .padding()
            }
            .navigationTitle("Il Mio Giardino")
            .navigationBarItems(trailing: Button(action: {
                showAddPlantSheet = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
            })
            .sheet(isPresented: $showAddPlantSheet) {
                AddPlantView(viewModel: viewModel)
            }
            .sheet(isPresented: Binding(
                get: { selectedPlant != nil },
                set: { if !$0 { selectedPlant = nil } }
            )) {
                if let selectedPlant = selectedPlant {
                    PlantDetailView(plant: selectedPlant, viewModel: viewModel)
                }
            }
        }
        .onAppear {
            viewModel.requestNotificationPermission()
        }
    }
}

// MARK: - Pianta Dettaglio (Vista Espansa)
struct PlantDetailView: View {
    var plant: Plant
    @ObservedObject var viewModel: GardenViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var newPlantImage: UIImage?
    @State private var showCamera = false

    let imageWidth: CGFloat = 300
    let imageHeight: CGFloat = 200

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Titolo della pianta
                Text(plant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0))
                    .padding(.top)

                // Descrizione e immagini esistenti...
                
                // Sezione per aggiungere nuove immagini
                Section(header: Text("Aggiungi Nuove Immagini")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Seleziona un'immagine dalla libreria")
                            .foregroundColor(.blue)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                newPlantImage = image
                            }
                        }
                    }
                    
                    Button("Scatta una foto") {
                        showCamera = true
                    }
                    .foregroundColor(.green1)
                    .sheet(isPresented: $showCamera) {
                        ImagePicker(image: $newPlantImage, sourceType: .camera)
                    }
                    
                    if let image = newPlantImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageWidth, height: imageHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 10)
                            .padding(.top)
                    }

                    Button("Aggiungi Immagine") {
                        if let newImage = newPlantImage {
                            viewModel.addImageToPlant(plant: plant, newImage: newImage)
                            newPlantImage = nil
                        }
                    }
                    .foregroundColor(.green)
                    .padding(.top)
                }
            }
            .padding()
            .background(Color(red: 1.0, green: 0.95, blue: 0.7).ignoresSafeArea())
        }
        .navigationTitle("Dettagli della Pianta")
    }
}
// MARK: - Add Plant View
struct AddPlantView: View {
    @ObservedObject var viewModel: GardenViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var plantName = ""
    @State private var plantDescription = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var plantImage: UIImage?
    @State private var wateringFrequency = 1 // Frequenza di innaffiatura (default 1 giorno)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nome della Pianta")) {
                    TextField("Inserisci il nome", text: $plantName)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                }
                
                Section(header: Text("Descrizione")) {
                    TextField("Inserisci una descrizione", text: $plantDescription)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                }
                
                Section(header: Text("Immagine della Pianta")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Seleziona un'immagine")
                            .foregroundColor(.blue)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                plantImage = image
                            }
                        }
                    }
                    
                    if let image = plantImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 10)
                            .padding(.top)
                    }
                }
                
                Section(header: Text("Frequenza Innaffiatura (giorni)")) {
                    Stepper("\(wateringFrequency) giorni", value: $wateringFrequency, in: 1...30)
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
                }
            }
            .navigationTitle("Aggiungi Pianta")
            .navigationBarItems(
                leading: Button("Annulla") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Salva") {
                    if !plantName.isEmpty {
                        viewModel.addPlant(name: plantName, description: plantDescription, image: plantImage, wateringFrequency: wateringFrequency)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.0)) // Verde scuro
            )
        }
    }
}

// MARK: - Main App
@main
struct MyGardenApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}

// Preview per la SplashScreen
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
