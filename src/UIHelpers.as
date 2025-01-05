/* tooltips */

void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}

// /* button */

void DisabledButton(const string &in text, const vec2 &in size = vec2 ( )) {
    UI::BeginDisabled();
    UI::Button(text, size);
    UI::EndDisabled();
}

bool MDisabledButton(bool disabled, const string &in text, const vec2 &in size = vec2 ( )) {
    if (disabled) {
        DisabledButton(text, size);
        return false;
    } else {
        return UI::Button(text, size);
    }
}

void CopyableText(const string &in text, const string &in toCopy = "") {
    UI::Text(text);
    if (UI::IsItemHovered()) {
        UI::SetMouseCursor(UI::MouseCursor::Hand);
    }
    if (UI::IsItemClicked(UI::MouseButton::Left)) {
        IO::SetClipboard(toCopy.Length > 0 ? text : toCopy);
        UI::ShowNotification("copied to clipboard", (toCopy.Length > 0 ? text : toCopy));
    }
}
