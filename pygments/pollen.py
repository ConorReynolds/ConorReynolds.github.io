from pygments.lexer import RegexLexer, bygroups, using
from pygments.lexers.lisp import RacketLexer
from pygments import token


__all__ = ['PollenLexer']


class PollenLexer(RegexLexer):
    name = 'Pollen Markup'
    aliases = ['pollen']
    filenames = ['*.*.pm']

    tokens = {
        'root': [
            (r'◊;.*?$', token.Comment),
            (r'[^◊]+', token.Text),
            (r'(◊)([\w/+-]+)({)',
                bygroups(token.Text, token.Keyword, token.Punctuation)),
            (r'(◊)([\w/+-]+)(\[)(.*?)(\])({)',
                bygroups(
                    token.Text,
                    token.Keyword,
                    token.Punctuation,
                    using(RacketLexer),
                    token.Punctuation,
                    token.Punctuation,
                )),
            (r'(◊)(\(.*\))', bygroups(token.Text, using(RacketLexer))),
            (r'}', token.Punctuation),
            (r'.*\n', token.Text),
        ],
    }

