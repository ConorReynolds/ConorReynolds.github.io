from pygments.lexer import RegexLexer, DelegatingLexer, bygroups, using
from pygments.lexers.lisp import RacketLexer
from pygments import token


class CustomLexer(DelegatingLexer):
    def __init__(self, **options) -> None:
        super().__init__(PollenMarkupLexer, RacketLexer, token.Other, **options)


class PollenMarkupLexer(RegexLexer):
    name = 'Pollen Markup'
    aliases = ['pollen']
    filenames = ['*.*.pm']

    tokens = {
        'root': [
            (r'\s+', token.Text),
            (r'◊;.*?$', token.Comment),
            (r'(◊)([\w-]+)({)(.*?)(})',
                bygroups(
                    token.Text,
                    token.Keyword,
                    token.Punctuation,
                    token.Text,
                    token.Punctuation
                )),
            (r'(◊)(\(.*?\))', bygroups(token.Text, token.Other)),
            (r'.*\n', token.Text),
        ],
    }

