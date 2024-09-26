// RegisteredObjectsListView.swift
import SwiftUI

struct RegisteredObjectsListView: View {
    @ObservedObject var viewModel: RegisteredObjectsViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.registeredObjects) { object in
                    RegisteredObjectRow(object: object, viewModel: viewModel)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationBarTitle("登録済みオブジェクト", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    // オブジェクトを削除する関数
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let object = viewModel.registeredObjects[index]
            viewModel.deleteObject(object)
        }
    }
}

struct RegisteredObjectsListView_Previews: PreviewProvider {
    static var previews: some View {
        RegisteredObjectsListView(viewModel: RegisteredObjectsViewModel())
    }
}
