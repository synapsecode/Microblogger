"""empty message

Revision ID: 9af8d33b3629
Revises: 58828f74f45c
Create Date: 2020-08-16 23:12:49.798663

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '9af8d33b3629'
down_revision = '58828f74f45c'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.add_column(sa.Column('isEdited', sa.Boolean(), nullable=True))

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('micro_blog_post', schema=None) as batch_op:
        batch_op.drop_column('isEdited')

    # ### end Alembic commands ###