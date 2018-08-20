//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tien Do on 11/26/17.
//  Copyright © 2017 Tien Do. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.unaryOperation(operation)
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    private var accumulator: Double?
    
    private var resultIsPending = false
    
    private var description = "" {
        didSet {
            print(description)
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equal
    }
    
    private var operations: [String:Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "C": Operation.constant(0),
        "√": Operation.unaryOperation({ sqrt($0) }),
//        "cos": Operation.unaryOperation({ cos($0) }),
        "±": Operation.unaryOperation({ -$0 }),
        "+": Operation.binaryOperation({ $0 + $1 }),
        "-": Operation.binaryOperation({ $0 - $1 }),
        "x": Operation.binaryOperation({ $0 * $1 }),
        "÷": Operation.binaryOperation({ $0 / $1 }),
        "=": Operation.equal
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            if symbol != "=" {
                description += symbol
            } else {
                description = ""
            }
            switch operation {
            case .constant(let value):
                accumulator = value
                if value == 0 {
                    pendingBinaryOperation = nil
                }
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperations(firstOperand: accumulator!, function: function)
                    if !resultIsPending {
                        resultIsPending = true
                    }
                    accumulator = nil
                }
            case .equal:
                performPendingBinaryOperation()
                resultIsPending = false
            }
        }
    }
    
    mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    private struct PendingBinaryOperations {
        var firstOperand: Double
        var function: (Double,Double) -> Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand,secondOperand)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperations?
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        description += "\(operand)"
    }    
    
}



