echo(len("Привет! 嗨"));

proc factorial(n: int): int =
    if n <= 1:
        return 1
    else:
        return n * factorial(n - 1)

echo(factorial(19))
