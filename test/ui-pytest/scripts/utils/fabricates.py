def generate_log_title(title: str, title_length: int = 80) -> str:
    space = title_length - 2 - len(title)
    return '\n' + int(space / 2) * '-' + ' ' + title + ' ' + int(space / 2) * '-'
