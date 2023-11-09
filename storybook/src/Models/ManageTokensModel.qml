import QtQuick 2.15
import QtQml.Models 2.15

import Models 1.0

ListModel {
    function randomizeData() {
        var data = []
        for (let i = 0; i < 100; i++) {
            const communityId = i % 2 == 0 ? "" : "communityId%1".arg(Math.round(i))
            const enabledNetworkBalance = !!communityId ? Math.round(i)
                                                        : {
                                                              amount: 1,
                                                              symbol: "ZRX"
                                                          }
            var obj = {
                name: "Item %1".arg(i),
                symbol: "SYM %1".arg(i),
                enabledNetworkBalance: enabledNetworkBalance,
                enabledNetworkCurrencyBalance: {
                    amount: 10.37,
                    symbol: "EUR",
                    displayDecimals: 2
                },
                communityId: communityId,
                communityName: "COM %1".arg(i),
                communityImage: ""
            }
            data.push(obj)
        }
        append(data)
    }

    readonly property var data: [
        {
            name: "0x",
            symbol: "ZRX",
            enabledNetworkBalance: {
                amount: 1,
                symbol: "ZRX"
            },
            enabledNetworkCurrencyBalance: {
                amount: 10.37,
                symbol: "EUR",
                displayDecimals: 2
            },
            communityId: "ddls",
            communityName: "Doodles",
            communityImage: ModelsData.collectibles.doodles // FIXME backend
        },
        {
            name: "Omg",
            symbol: "OMG",
            enabledNetworkBalance: {
                amount: 2,
                symbol: "OMG"
            },
            enabledNetworkCurrencyBalance: {
                amount: 13.37,
                symbol: "EUR",
                displayDecimals: 2
            },
            communityId: "sox",
            communityName: "Socks",
            communityImage: ModelsData.icons.socks
        },
        {
            name: "Decentraland",
            symbol: "MANA",
            enabledNetworkBalance: {
                amount: 301,
                symbol: "MANA"
            },
            enabledNetworkCurrencyBalance: {
                amount: 75.256,
                symbol: "EUR",
                displayDecimals: 2
            },
            changePct24hour: -2.1,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "Ave Maria",
            symbol: "AAVE",
            enabledNetworkBalance: {
                amount: 23.3,
                symbol: "AAVE",
                displayDecimals: 2
            },
            enabledNetworkCurrencyBalance: {
                amount: 2.335,
                symbol: "EUR",
                displayDecimals: 2
            },
            changePct24hour: 4.56,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "Polymorphism",
            symbol: "POLY",
            enabledNetworkBalance: {
                amount: 3590,
                symbol: "POLY"
            },
            enabledNetworkCurrencyBalance: {
                amount: 2.7,
                symbol: "EUR",
                displayDecimals: 2
            },
            changePct24hour: -11.6789,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "Dai",
            symbol: "DAI",
            enabledNetworkBalance: {
                amount: 634.22,
                symbol: "DAI",
                displayDecimals: 2
            },
            enabledNetworkCurrencyBalance: {
                amount: 594.72,
                symbol: "EUR",
                displayDecimals: 2
            },
            changePct24hour: 0,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "Makers' choice",
            symbol: "MKR",
            enabledNetworkBalance: {
                amount: 1.3,
                symbol: "MKR",
                displayDecimals: 2
            },
            enabledNetworkCurrencyBalance: {
                amount: 100.37,
                symbol: "EUR",
                displayDecimals: 2
            },
            changePct24hour: -1,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "Ethereum",
            symbol: "ETH",
            enabledNetworkBalance: {
                amount: 0.12345,
                symbol: "ETH",
                displayDecimals: 8,
                stripTrailingZeroes: true
            },
            enabledNetworkCurrencyBalance: {
                amount: 182.72,
                symbol: "EUR",
                displayDecimals: 2
            },
            changePct24hour: -3.51,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "GetOuttaHere",
            symbol: "InvisibleSYM",
            enabledNetworkBalance: {},
            enabledNetworkCurrencyBalance: {},
            changePct24hour: NaN,
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            enabledNetworkBalance: ({
                                        displayDecimals: true,
                                        stripTrailingZeroes: true,
                                        amount: 324343.3,
                                        symbol: "SNT"
                                    }),
            enabledNetworkCurrencyBalance: ({
                                                displayDecimals: 4,
                                                stripTrailingZeroes: true,
                                                amount: 2.333321323400,
                                                symbol: "EUR"
                                            }),
            symbol: "SNT",
            name: "Status",
            communityId: "",
            communityName: "",
            communityImage: ""
        },
        {
            name: "Meth",
            symbol: "MET",
            enabledNetworkBalance: {
                amount: 666,
                symbol: "MET"
            },
            enabledNetworkCurrencyBalance: {
                amount: 1000.37,
                symbol: "EUR",
                displayDecimals: 2
            },
            communityId: "ddls",
            communityName: "Doodles",
            communityImage: ModelsData.collectibles.doodles
        },
        {
            name: "Ast",
            symbol: "AST",
            enabledNetworkBalance: {
                amount: 1,
                symbol: "AST"
            },
            enabledNetworkCurrencyBalance: {
                amount: 0.374,
                symbol: "EUR",
                displayDecimals: 2
            },
            communityId: "ast",
            communityName: "Astafarians",
            communityImage: ModelsData.icons.dribble
        }
    ]
    Component.onCompleted: append(data)
}