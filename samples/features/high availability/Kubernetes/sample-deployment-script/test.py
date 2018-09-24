import argparse


if __name__ == "__main__":
    git_parser = argparse.ArgumentParser(prog="git")
    git_add_parser = argparse.ArgumentParser(prog="add")
    git_add_parser.prog = "ADD"
    git_commit_parser = argparse.ArgumentParser(prog="commit")

    subparsers = git_parser.add_subparsers()

    subparsers.add_parser(prog=git_add_parser.prog)
    subparsers.add_parser(git_commit_parser.prog)

    git_parser.parse_args(["--help"])
