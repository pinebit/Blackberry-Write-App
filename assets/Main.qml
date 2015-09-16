import bb.cascades 1.4

NavigationPane {
    id: navigationPane
    
    Page {
        Container {
            Container {
                topPadding: ui.sdu(1)
                bottomPadding: ui.sdu(1)
                leftPadding: ui.sdu(2)
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                visible: _notes.hasNotes
                background: Color.create("#101010")
                
                ImageView {
                    imageSource: "asset:///images/ic_search_sm.png"
                    verticalAlignment: VerticalAlignment.Center
                }
                TextField {
                    id: searchField
                    backgroundVisible: false
                    hintText: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
                    verticalAlignment: VerticalAlignment.Center
                    onTextChanging: {
                        _notes.setFilter(text.trim())
                    }
                }
            }
            
            Container {
                visible: !_notes.hasNotes
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                topMargin: ui.sdu(10)
                Label {
                    text: qsTr("No items") + Retranslate.onLocaleOrLanguageChanged
                    textStyle.base: SystemDefaults.TextStyles.BigText
                    textStyle.color: ui.palette.plain
                }
            }
            
            ListView {
                id: notesList
                dataModel: _notes.model
                visible: _notes.hasNotes
                
                listItemComponents: [
                    ListItemComponent {
                        type: "item"
                        Container {
                            Container {
                                topPadding: ui.sdu(4)
                                bottomPadding: ui.sdu(2)
                                leftPadding: ui.sdu(2)
                                rightPadding: ui.sdu(2)

                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                horizontalAlignment: HorizontalAlignment.Fill

                                Label {
                                    text: ListItemData.subject
                                    layoutProperties: StackLayoutProperties {
                                        spaceQuota: 1
                                    }
                                }
                                Label {
                                    text: ListItemData.displayDate
                                    horizontalAlignment: HorizontalAlignment.Right
                                    textStyle.color: ui.palette.secondaryTextOnPlain
                                }
                            }
                            Divider {
                            }
                        }
                    }
                ]
                
                onTriggered: {
                    var selectedItem = dataModel.data(indexPath);
                    var noteId = selectedItem.noteId;
                    var page = editorPage.createObject()
                    page.editNote(noteId)
                    push(page)
                }
            }
        }

        actions: [
            ActionItem {
                title: qsTr("New") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_compose.png"
                ActionBar.placement: ActionBarPlacement.Signature
                onTriggered: {
                    var page = editorPage.createObject()
                    page.newNote()
                    push(page)
                }
            },
            ActionItem {
                title: qsTr("Settings") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_settings.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    push(settingsPage.createObject())
                }
            },
            ActionItem {
                title: qsTr("Password") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_lock.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    push(passwordPage.createObject())
                }
            }
        ]
    }

    onPopTransitionEnded: {
        page.destroy();
    }

    onCreationCompleted: {
        Application.thumbnail.connect(requirePassword);

        searchField.requestFocus()
        requirePassword()
    }
    
    function requirePassword() {
        var passwordHash = _app.getSetting("password-hash", "")
        if (passwordHash != "") {
            unlockScreen.open()
        }
    }

    attachedObjects: [
        Unlock {
            id: unlockScreen
        },
        ComponentDefinition {
            id: settingsPage
            Settings {
            }
        },
        ComponentDefinition {
            id: passwordPage
            Password {
            }
        },
        ComponentDefinition {
            id: editorPage
            Editor {
            }
        }
    ]
}
