//
//  CashBoardDemo.swift
//  AppleLearn
//
//  Created by baronyang on 2024/4/3.
//

import SwiftUI
import CloudKit

// 主视图结构体
struct CashBoardDemo: View {
    @State private var balance: Double = 1000.0
    @State private var transactions: [Transaction] = []
    
    // 用于iCloud同步的数据库
    private let database = CKContainer.default().privateCloudDatabase
    
    var body: some View {
        NavigationView {
            VStack {
                BalanceView(balance: balance)
                
                TransactionList(transactions: transactions)
                
                AddTransactionButton(addTransaction: addTransaction)
                
                // 添加CSV导入按钮
                ImportCSVButton(importCSV: importCSV)
            }
            .navigationTitle("资金管理")
            .onAppear(perform: loadTransactions)
        }
    }
    
    // 添加新交易
    func addTransaction(amount: Double, type: TransactionType) {
        let newTransaction = Transaction(amount: amount, type: type, date: Date())
        transactions.append(newTransaction)
        
        if type == .income {
            balance += amount
        } else {
            balance -= amount
        }
        
        // 保存到iCloud
        saveTransactionToCloud(newTransaction)
    }
    
    // 从iCloud加载交易记录
    func loadTransactions() {
        let query = CKQuery(recordType: "Transaction", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("从iCloud加载交易记录失败: \(error.localizedDescription)")
                return
            }
            
            guard let records = records else { return }
            
            DispatchQueue.main.async {
                self.transactions = records.compactMap { record in
                    guard let amount = record["amount"] as? Double,
                          let typeRaw = record["type"] as? Int,
                          let date = record["date"] as? Date else {
                        return nil
                    }
                    let type = TransactionType(rawValue: typeRaw) ?? .expense
                    return Transaction(amount: amount, type: type, date: date)
                }
                self.updateBalance()
            }
        }
    }
    
    // 保存交易记录到iCloud
    func saveTransactionToCloud(_ transaction: Transaction) {
        let record = CKRecord(recordType: "Transaction")
        record["amount"] = transaction.amount
        record["type"] = transaction.type.rawValue
        record["date"] = transaction.date
        
        database.save(record) { (_, error) in
            if let error = error {
                print("保存到iCloud失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 更新余额
    func updateBalance() {
        balance = transactions.reduce(0) { $0 + ($1.type == .income ? $1.amount : -$1.amount) }
    }
    
    // 导入CSV文件
    func importCSV() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.commaSeparatedText]
        
        panel.beginSheetModal(for: NSApp.keyWindow!) { response in
            if response == .OK, let url = panel.url {
                self.parseCSV(from: url)
            }
        }
    }
    
    private func parseCSV(from url: URL) {
        do {
            let csvContent = try String(contentsOf: url)
            let rows = csvContent.components(separatedBy: .newlines)
            
            var newTransactions: [Transaction] = []
            
            for row in rows.dropFirst() { // 假设第一行是标题
                let columns = row.components(separatedBy: ",")
                if columns.count >= 3,
                   let amount = Double(columns[0]),
                   let typeRaw = Int(columns[1]),
                   let date = DateFormatter().date(from: columns[2]) {
                    let type = TransactionType(rawValue: typeRaw) ?? .expense
                    let transaction = Transaction(amount: amount, type: type, date: date)
                    newTransactions.append(transaction)
                }
            }
            
            DispatchQueue.main.async {
                self.transactions.append(contentsOf: newTransactions)
                self.updateBalance()
                
                // 保存新导入的交易记录到iCloud
                for transaction in newTransactions {
                    self.saveTransactionToCloud(transaction)
                }
            }
        } catch {
            print("CSV文件解析失败: \(error.localizedDescription)")
        }
    }
}

// 余额视图
struct BalanceView: View {
    let balance: Double
    
    var body: some View {
        VStack {
            Text("当前余额")
                .font(.headline)
            Text("¥\(balance, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

// 交易列表视图
struct TransactionList: View {
    let transactions: [Transaction]
    
    var body: some View {
        List(transactions) { transaction in
            HStack {
                Text(transaction.type == .income ? "收入" : "支出")
                    .foregroundColor(transaction.type == .income ? .green : .red)
                Spacer()
                Text("¥\(transaction.amount, specifier: "%.2f")")
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// 添加交易按钮
struct AddTransactionButton: View {
    @State private var showingAddTransaction = false
    let addTransaction: (Double, TransactionType) -> Void
    
    var body: some View {
        Button(action: {
            showingAddTransaction = true
        }) {
            Text("添加交易")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(addTransaction: addTransaction)
        }
    }
}

// 添加交易视图
struct AddTransactionView: View {
    @State private var amount: String = ""
    @State private var type: TransactionType = .income
    @Environment(\.presentationMode) var presentationMode
    let addTransaction: (Double, TransactionType) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("金额", text: $amount)
                    .keyboardType(.decimalPad)
                
                Picker("类型", selection: $type) {
                    Text("收入").tag(TransactionType.income)
                    Text("支出").tag(TransactionType.expense)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button("添加") {
                    if let amountDouble = Double(amount) {
                        addTransaction(amountDouble, type)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("添加交易")
        }
    }
}

// 导入CSV按钮
struct ImportCSVButton: View {
    let importCSV: () -> Void
    
    var body: some View {
        Button(action: importCSV) {
            Text("导入CSV")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

// 交易记录结构体
struct Transaction: Identifiable {
    let id = UUID()
    let amount: Double
    let type: TransactionType
    let date: Date
}

// 交易类型枚举
enum TransactionType: Int {
    case income
    case expense
}

// 预览提供者
struct CashBoardDemo_Previews: PreviewProvider {
    static var previews: some View {
        CashBoardDemo()
    }
}
