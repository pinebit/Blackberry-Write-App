import bb.cascades 1.4
import bb.system 1.2

Sheet {
    peekEnabled: false

    onOpened: {
        passwordField.requestFocus()
    }
    
    onClosed: {
        passwordField.text = ""
    }

    Page {
        Container {
            topPadding: ui.sdu(8)
            leftPadding: ui.sdu(5)
            rightPadding: ui.sdu(5)

            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                ImageView {
                    imageSource: "asset:///images/ic_lock.png"

                }
                Label {
                    text: qsTr("Unlock & Write!") + Retranslate.onLocaleOrLanguageChanged
                    textStyle.base: SystemDefaults.TextStyles.BigText
                }
            }

            Label {
                topMargin: ui.sdu(8)
                text: qsTr("Enter your password to unlock:") + Retranslate.onLocaleOrLanguageChanged
            }

            TextField {
                id: passwordField
                hintText: qsTr("Password") + Retranslate.onLocaleOrLanguageChanged
                inputMode: TextFieldInputMode.Password
                input.submitKey: SubmitKey.Submit
                input.onSubmitted: {
                    if (unlockButton.enabled) {
                        unlockButton.clicked()
                    }
                }
                onTextChanging: {
                    unlockButton.enabled = passwordField.text.trim() != "";
                }
                validator: Validator {
                    id: passwordValidator
                    mode: ValidationMode.Custom
                    errorMessage: qsTr("Wrong password") + Retranslate.onLocaleOrLanguageChanged
                    onValidate: {
                        var passwordHash = _app.getSetting("password-hash", "")
                        var userHash = Qt.md5(passwordField.text)
                        if (passwordHash != userHash) {
                            state = ValidationState.Invalid
                        } else {
                            state = ValidationState.Valid
                        }
                    }
                }
            }

            Button {
                id: unlockButton
                topMargin: ui.sdu(4)
                text: qsTr("Unlock") + Retranslate.onLocaleOrLanguageChanged
                enabled: false
                appearance: ControlAppearance.Primary
                horizontalAlignment: HorizontalAlignment.Fill

                onClicked: {
                    passwordValidator.validate()
                    if (passwordValidator.valid) {
                        close()
                    }
                }
            }
        }
    }
}
