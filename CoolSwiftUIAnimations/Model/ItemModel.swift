//
//  Item.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 26.06.25.
//

import SwiftUI

struct ItemModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

extension ItemModel {
    /// Sample data for dog themed assets used in previews or tests.
    static let dogSamples: [ItemModel] = [
        ItemModel(
            title: "Berlin Pupper",
            description: "A curious dog exploring the streets of Berlin.",
            imageName: "berlinPupper"
        ),
        ItemModel(
            title: "Box Pupper",
            description: "Playful pup hiding inside a cardboard box.",
            imageName: "boxPupper"
        ),
        ItemModel(
            title: "Cool Pupper",
            description: "Laid back dog sporting stylish shades.",
            imageName: "coolPupper"
        ),
        ItemModel(
            title: "Excited Pupper",
            description: "Energetic dog ready for fun adventures.",
            imageName: "excitedPupper"
        ),
        ItemModel(
            title: "Halloween Pupper",
            description: "Dog dressed up for spooky Halloween nights.",
            imageName: "halloweenPupper"
        ),
        ItemModel(
            title: "Patriotic Pupper",
            description: "Proud pup showing off patriotic colors.",
            imageName: "patrioticPupper"
        ),
        ItemModel(
            title: "Reading Pupper",
            description: "Studious dog enjoying a good book.",
            imageName: "readingPupper"
        ),
        ItemModel(
            title: "Stick Hunter Pupper",
            description: "Dog happily chasing the perfect stick.",
            imageName: "stickHunterPupper"
        ),
        ItemModel(
            title: "Tile Pupper",
            description: "Relaxed pup lying on a cool tiled floor.",
            imageName: "tilePupper"
        ),
        ItemModel(
            title: "Urban Pupper",
            description: "City dwelling dog enjoying the urban life.",
            imageName: "urbanPupper"
        ),
        ItemModel(
            title: "Well Behaved Pupper",
            description: "Obedient pup posing politely for the camera.",
            imageName: "wellbehavedPupper"
        )
    ]

    /// Sample data for scenic background assets used in previews or tests.
    static let sceneSamples: [ItemModel] = [
        ItemModel(
            title: "Ancient Tree",
            description: "Mighty tree standing tall through the ages.",
            imageName: "ancientTree"
        ),
        ItemModel(
            title: "Autumn River",
            description: "Gentle river surrounded by autumn colors.",
            imageName: "autumnRiver"
        ),
        ItemModel(
            title: "Cloudy Dolomites",
            description: "Mountain peaks covered in dramatic clouds.",
            imageName: "cloudyDolomites"
        ),
        ItemModel(
            title: "Forest Dawn",
            description: "Early morning light filtering through trees.",
            imageName: "forestDawn"
        ),
        ItemModel(
            title: "Green Forest",
            description: "Lush greenery filling a vibrant forest.",
            imageName: "greenForest"
        ),
        ItemModel(
            title: "Mountain Dawn",
            description: "Sunrise breaking over towering mountains.",
            imageName: "mountainDawn"
        ),
        ItemModel(
            title: "Redwood Forest",
            description: "Gigantic redwoods reaching for the sky.",
            imageName: "redwoodForest"
        ),
        ItemModel(
            title: "Sunset Hill",
            description: "Warm sun setting over peaceful hills.",
            imageName: "sunsetHill"
        ),
        ItemModel(
            title: "Snowy Mountain Sunset",
            description: "Sunset glow on a snow-covered mountain.",
            imageName: "sunsetSnowyMountain"
        ),
        ItemModel(
            title: "Sunset Tide",
            description: "Ocean waves glimmering at sundown.",
            imageName: "sunsetTide"
        )
    ]

    /// Sample data of all asets used in previews or tests.
    static let allSamples: [ItemModel] = dogSamples + sceneSamples
}
