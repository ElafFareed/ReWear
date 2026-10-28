//
//  RepairData.swift
//  RREEUUSSE
//
//  Created by shatha on 14/05/1448 AH.
//

import Foundation

// Main Dataset

struct RepairDataset: Decodable {
    let schemaVersion: String
    let datasetName: String
    let description: String
    let language: String
    let guides: [RepairGuide]
}

// Repair Guide

struct RepairGuide: Decodable, Identifiable {
    let id: String
    let problem: RepairProblem
    let repair: RepairInstructions
}

//  Problem

struct RepairProblem: Decodable {
    let name: String
    let description: String
}

// Repair Instructions

struct RepairInstructions: Decodable {
    let title: String
    let summary: String
    let bestFor: String
    let beforeYouBegin: String
    let materials: [String]
    let steps: [RepairStep]
    let imageName: String?
}

// Repair Steps

struct RepairStep: Decodable, Identifiable {
    let stepNumber: Int
    let instruction: String

    var id: Int { stepNumber }
}

// Load Dataset

enum RepairData {

    static func loadGuides() -> [RepairGuide] {
        guard let url = Bundle.main.url(
            forResource: "repairGuides",
            withExtension: "json"
        ) else {
            print("Could not find repairGuides.json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let dataset = try JSONDecoder().decode(
                RepairDataset.self,
                from: data
            )

            return dataset.guides

        } catch {
            print("Dataset error: \(error)")
            return []
        }
    }
}

