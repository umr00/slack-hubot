# -*- coding: utf-8 -*-

"""Console script for sdlab."""
import sys
import click


@click.command()
def dump_brain():
    import json
    from sdlab.brain import load_brain

    brain = load_brain()
    click.echo(json.dumps(brain, indent=2, ensure_ascii=False))


@click.command()
@click.argument('dump_filename', type=click.Path(exists=True))
def restore_brain(dump_filename):
    import json
    from sdlab.brain import restore_brain

    brain = json.load(open(dump_filename))
    click.echo('restore brain from {}'.format(dump_filename))
    restore_brain(brain)


@click.command()
def clean_brain():
    from sdlab.brain import clear_brain_trash
    clear_brain_trash()
    pass


@click.command()
@click.argument('brain_dump_file', type=click.Path(exists=True))
def convert_plusplus_brain(brain_dump_file):
    import json
    from sdlab.plusplus import convert_hubot_brain_to_bolt_redis
    with open(brain_dump_file) as f:
        brain = json.load(f)
        convert_hubot_brain_to_bolt_redis(brain)

@click.command()
def main(args=None):
    """Console script for sdlab."""
    click.echo("Replace this message by putting your code into "
               "sdlab.cli.main")
    click.echo("See click documentation at http://click.pocoo.org/")
    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
