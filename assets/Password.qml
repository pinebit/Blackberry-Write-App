import bb.cascades 1.4
import bb.system 1.2

Page {
    property bool hasPassword: false

    onCreationCompleted: {
        hasPassword = _app.getSetting("password-hash", "") != ""
        if (hasPassword) {
            currentPasswordField.requestFocus()
        } else {
            newPasswordField.requestFocus()
        }
    }

    titleBar: TitleBar {
        title: qsTr("Password") + Retranslate.onLocaleOrLanguageChanged

        acceptAction: ActionItem {
            title: qsTr("Save") + Retranslate.onLocaleOrLanguageChanged
            onTriggered: {
                if (hasPassword) {
                    passwordValidator.validate()
                    if (! passwordValidator.valid) {
                        return
                    }
                }

                newPasswordValidator.validate();
                confirmPasswordValidator.validate();
                if (newPasswordValidator.valid && confirmPasswordValidator.valid) {
                    var newPasswordHash = Qt.md5(newPasswordField.text)
                    _app.setSetting("password-hash", newPasswordHash)
                    passwordSetToast.show()
                }
            }
        }
    }

    Container {
        leftPadding: ui.sdu(4)
        topPadding: ui.sdu(4)
        rightPadding: ui.sdu(4)
        bottomPadding: ui.sdu(4)

        TextField {
            id: currentPasswordField
            visible: hasPassword
            topMargin: ui.sdu(1)
            inputMode: TextFieldInputMode.Password
            hintText: qsTr("Current password") + Retranslate.onLocaleOrLanguageChanged
            input.submitKey: SubmitKey.Next
            input.onSubmitted: {
                newPasswordField.requestFocus()
            }
            validator: Validator {
                id: passwordValidator
                mode: ValidationMode.Custom
                errorMessage: qsTr("Wrong password") + Retranslate.onLocaleOrLanguageChanged
                onValidate: {
                    var passwordHash = _app.getSetting("password-hash", "")
                    var userHash = Qt.md5(currentPasswordField.text)
                    if (passwordHash != userHash) {
                        state = ValidationState.Invalid
                    } else {
                        state = ValidationState.Valid
                    }
                }
            }
        }

        TextField {
            id: newPasswordField
            topMargin: ui.sdu(1)
            inputMode: TextFieldInputMode.Password
            hintText: qsTr("New password") + Retranslate.onLocaleOrLanguageChanged
            input.submitKey: SubmitKey.Next
            input.onSubmitted: {
                confirmPasswordField.requestFocus()
            }
            validator: Validator {
                id: newPasswordValidator
                mode: ValidationMode.FocusLost
                errorMessage: qsTr("Requied field") + Retranslate.onLocaleOrLanguageChanged
                onValidate: {
                    if (newPasswordField.text.trim() == "") {
                        state = ValidationState.Invalid
                    } else {
                        state = ValidationState.Valid
                    }
                }
            }
        }

        TextField {
            id: confirmPasswordField
            topMargin: ui.sdu(1)
            inputMode: TextFieldInputMode.Password
            hintText: qsTr("Confirm password") + Retranslate.onLocaleOrLanguageChanged
            input.submitKey: SubmitKey.Done
            input.onSubmitted: {
                titleBar.acceptAction.triggered()
            }
            validator: Validator {
                id: confirmPasswordValidator
                mode: ValidationMode.FocusLost
                errorMessage: qsTr("Password does not match") + Retranslate.onLocaleOrLanguageChanged
                onValidate: {
                    if (newPasswordField.text != confirmPasswordField.text) {
                        state = ValidationState.Invalid
                    } else {
                        state = ValidationState.Valid
                    }
                }
            }
        }

        Divider {
            topMargin: ui.sdu(4)
        }

        Button {
            topMargin: ui.sdu(4)
            text: qsTr("Remove Password") + Retranslate.onLocaleOrLanguageChanged
            horizontalAlignment: HorizontalAlignment.Fill
            visible: hasPassword
            onClicked: {
                passwordValidator.validate()
                if (! passwordValidator.valid) {
                    return
                }

                _app.setSetting("password-hash", "")
                hasPassword = false
                passwordRemovedToast.show()
            }
        }
    }

    attachedObjects: [
        SystemToast {
            id: passwordRemovedToast
            body: qsTr("Password removed") + Retranslate.onLocaleOrLanguageChanged
            onFinished: navigationPane.pop()
        },
        SystemToast {
            id: passwordSetToast
            body: qsTr("Password has been set") + Retranslate.onLocaleOrLanguageChanged
            onFinished: navigationPane.pop()
        }
    ]
}
