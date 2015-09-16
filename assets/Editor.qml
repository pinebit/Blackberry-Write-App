import bb.cascades 1.4
import bb.system 1.2

Page {
    id: editorPage
    property string noteId
    
    function newNote() {
        noteId = _notes.createNote()
        editorArea.text = ""
        enableEditing()
    }

    function editNote(editNoteId) {
        noteId = editNoteId
        editorArea.text = _notes.readNote(noteId)
    }

    function enableEditing() {
        editorArea.editable = true
        editorArea.requestFocus()

        actionBarVisibility = ChromeVisibility.Compact
        navigationPane.backButtonsVisible = false
        editorPage.removeAction(deleteAction)
        editorPage.removeAction(shareAction)
        editorPage.removeAction(newAction)
        editorPage.addAction(saveAction)
        editorPage.addAction(cancelAction)
    }
    
    function disableEditing() {
        editorPage.addAction(deleteAction)
        editorPage.addAction(shareAction)
        editorPage.addAction(newAction)
        editorPage.removeAction(saveAction)
        editorPage.removeAction(cancelAction)
        editorArea.editable = false
        
        scrollView.scrollToPoint(0, 0)
        actionBarVisibility = ChromeVisibility.Visible
        navigationPane.backButtonsVisible = true
    }

    onCreationCompleted: {
        editorArea.textStyle.fontFamily = _app.getSetting("font-family", "Sans-Serif")

        // Looks like QVariant cannot convert to FontSize..        
        var fsize = _app.getSetting("font-size", "100")
        switch (fsize)
        {
            case "80":
                editorArea.textStyle.fontSize = FontSize.XSmall
                break;
            
            case "90":
                editorArea.textStyle.fontSize = FontSize.Small
                break;
            
            case "100":
                editorArea.textStyle.fontSize = FontSize.Medium
                break;
            
            case "110":
                editorArea.textStyle.fontSize = FontSize.Large
                break;
            
            case "120":
                editorArea.textStyle.fontSize = FontSize.XLarge
                break;
        }
        
        disableEditing()
    }

    Container {
        topPadding: ui.sdu(2)
        layout: DockLayout {
        }

        ScrollView {
            id: scrollView
            verticalAlignment: VerticalAlignment.Fill
            Container {
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                Label {
                    text: Qt.formatDateTime(_notes.noteDateTime(noteId), "MMMM d yyyy, h:mm ap")
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.color: ui.palette.secondaryTextOnPlain
                    textStyle.fontSize: FontSize.Small
                }
                TextArea {
                    id: editorArea
                    inputMode: TextAreaInputMode.Text
                    minHeight: DisplayInfo.height
                    backgroundVisible: false
                    textStyle.color: Color.White

                    gestureHandlers: [
                        TapHandler {
                            onTapped: enableEditing()
                        }
                    ]
                }
            }
        }
    }
    
    actions: [
        ActionItem {
            id: deleteAction
            title: qsTr("Delete") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_delete.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                deleteNoteDialog.exec()
                if (deleteNoteDialog.result == SystemUiResult.ConfirmButtonSelection) {
                    _notes.deleteNote(noteId)
                    navigationPane.pop()
                }
            }
        },
        InvokeActionItem {
            id: shareAction
            ActionBar.placement: ActionBarPlacement.OnBar
            title: "Share"
            imageSource: "asset:///images/ic_share.png"
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: {
                data = editorArea.text.trim()
            }
        },
        ActionItem {
            id: newAction
            title: qsTr("New") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_compose.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                newNote()
            }
        },
        ActionItem {
            id: saveAction
            title: qsTr("Save") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_done.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                _notes.saveNote(noteId, editorArea.text)
                disableEditing()
            }
        },
        ActionItem {
            id: cancelAction
            title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_cancel.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                disableEditing()
            }
        }
    ]

    attachedObjects: [
        SystemDialog {
            id: deleteNoteDialog
            title: qsTr("Warning") + Retranslate.onLocaleOrLanguageChanged
            body: qsTr("All text will be deleted. Forever.") + Retranslate.onLocaleOrLanguageChanged
        },
        SystemToast {
            id: copiedToast
            body: qsTr("All text is copied to the clipboard.") + Retranslate.onLocaleOrLanguageChanged
        }
    ]
}
