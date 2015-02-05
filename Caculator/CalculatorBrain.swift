//
//  CalculatorBrain.swift
//  Caculator
//
//  Created by gph on 15/2/3.
//  Copyright (c) 2015年 gph. All rights reserved.
//

import Foundation

//Clculator Brain 计算器的大脑
class CalculatorBrain
{
    private enum Op: Printable
        // Op 运算、操作,  
        // Printable 是 Protocol, 这个protpcol恰好是叫做description的property，可以返回一个Sting
    {
        case Operand(Double)    //操作数
        case UnaryOperation(String, Double -> Double)   //一元运算
        case BinaryOperation(String, (Double, Double) -> Double)    //二元运算
        
        var description:String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()    //操作栈
    
    private var knownOps = [String:Op]()    //已知的运算
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        knownOps["×"] = Op.BinaryOperation("×", *)          // 等同于 ("×") { $0 * $1 }
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)          // 等同于 ("+") { $0 + $1 }
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)        // 等同于 ("√") { sqrt($0) }
        

    }

//  evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) 参数：result 结果，remainingOps 剩下的操作
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
//  evaluate() 求…的数值
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }

//  pushOperand(operand: Double)   把操作数压入堆栈
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
//  performOperation(symbol: String)    执行操作
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}

