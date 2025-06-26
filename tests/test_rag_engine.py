import os
import sys
import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from rag_engine import search_knowledge


def test_search_knowledge_word_match():
    chunks = [
        "This is a hello text",
        "Another world piece",
        "Completely unrelated",
    ]
    result = search_knowledge("hello world", chunks, threshold=0.9)
    assert result == [
        "Another world piece",
        "This is a hello text",
    ]


def test_search_knowledge_sequence_ratio():
    chunks = ["hello"]
    result = search_knowledge("helo", chunks)
    assert result == ["hello"]


def test_search_knowledge_punctuation_removed():
    chunks = ["hello world", "foo bar"]
    result = search_knowledge("Hello, world!", chunks, threshold=1.1)
    assert result == ["hello world"]
