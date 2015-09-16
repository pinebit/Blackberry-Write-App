import bb.cascades 1.4

Page {
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged

        acceptAction: ActionItem {
            title: qsTr("Save") + Retranslate.onLocaleOrLanguageChanged
            onTriggered: {
                _app.setSetting("font-family", fontFamilySelector.selectedValue)
                _app.setSetting("font-size", fontSizeSelector.selectedValue)
                navigationPane.pop()
            }
        }
    }

    function setDropDownOptionByValue(dropdown, value) {
        for (var i = 0; i < dropdown.options.length; i ++) {
            var o = dropdown.options[i];
            if (o.value == value) {
                dropdown.setSelectedOption(o);
                return;
            }
        }
    }

    onCreationCompleted: {
        var fontFamily = _app.getSetting("font-family", "Sans-Serif")
        var fontSize = _app.getSetting("font-size", FontSize.Medium)
        setDropDownOptionByValue(fontFamilySelector, fontFamily)
        setDropDownOptionByValue(fontSizeSelector, fontSize)
    }

    Container {
        leftPadding: ui.sdu(4)
        topPadding: ui.sdu(4)
        rightPadding: ui.sdu(4)
        bottomPadding: ui.sdu(4)

        DropDown {
            id: fontFamilySelector
            title: qsTr("Font Style") + Retranslate.onLocaleOrLanguageChanged
            selectedIndex: 0
            options: [
                Option {
                    text: qsTr("Sans-Serif") + Retranslate.onLocaleOrLanguageChanged
                    value: text
                },
                Option {
                    text: qsTr("Serif") + Retranslate.onLocaleOrLanguageChanged
                    value: text
                },
                Option {
                    text: qsTr("Monospace") + Retranslate.onLocaleOrLanguageChanged
                    value: text
                },
                Option {
                    text: qsTr("Cursive") + Retranslate.onLocaleOrLanguageChanged
                    value: text
                },
                Option {
                    text: qsTr("Fantasy") + Retranslate.onLocaleOrLanguageChanged
                    value: text
                }
            ]
        }

        DropDown {
            id: fontSizeSelector
            title: qsTr("Font Size") + Retranslate.onLocaleOrLanguageChanged
            selectedIndex: 2
            options: [
                Option {
                    text: qsTr("Extra Large") + Retranslate.onLocaleOrLanguageChanged
                    value: FontSize.XLarge
                },
                Option {
                    text: qsTr("Large") + Retranslate.onLocaleOrLanguageChanged
                    value: FontSize.Large
                },
                Option {
                    text: qsTr("Normal") + Retranslate.onLocaleOrLanguageChanged
                    value: FontSize.Medium
                },
                Option {
                    text: qsTr("Small") + Retranslate.onLocaleOrLanguageChanged
                    value: FontSize.Small
                },
                Option {
                    text: qsTr("Extra Small") + Retranslate.onLocaleOrLanguageChanged
                    value: FontSize.XSmall
                }
            ]
        }

        Container {
            background: Color.DarkGray
            topMargin: ui.sdu(4)
            topPadding: ui.sdu(2)
            bottomPadding: ui.sdu(2)
            leftPadding: ui.sdu(2)
            rightPadding: ui.sdu(2)
            
            Container {
                background: Color.Black
                TextArea {
                    textStyle.color: Color.White
                    textStyle.fontFamily: fontFamilySelector.selectedValue
                    textStyle.fontSize: fontSizeSelector.selectedValue
                    editable: false
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
                }
            }
        }
    }
}
