# -*- coding: utf-8 -*-
import a2ctrl
from a2qt import QtWidgets
from a2element import DrawCtrl, EditCtrl
from a2widget.a2item_editor import A2ItemEditor
from a2widget.key_value_table import KeyValueTable


class Draw(DrawCtrl):
    """
    The frontend widget visible to the user with options
    to change the default behavior of the element.
    """
    def __init__(self, *args):
        super(Draw, self).__init__(*args)
        self.main_layout = QtWidgets.QVBoxLayout(self)
        self.main_layout.setContentsMargins(0, 0, 0, 0)

        self.editor = UniFormatLister(self.user_cfg, self)
        self.editor.data_changed.connect(self.delayed_check)
        self.main_layout.addWidget(self.editor)
        self.is_expandable_widget = True

    def check(self):
        self.user_cfg = self.editor.data
        self.set_user_value(self.user_cfg)
        self.change()


class UniFormatLister(A2ItemEditor):
    def __init__(self, cfg, parent):
        self.draw_ctrl = parent
        self.data = cfg or {}
        super().__init__(parent)

        self.key_value_table = KeyValueTable(self)
        self.key_value_table.changed.connect(self._update_data)
        self.enlist_widget('data', self.key_value_table, self.key_value_table.set_data, {})
        self.add_row(self.key_value_table)

    def _update_data(self):
        if self.selected_name:
            have_data = self.data[self.selected_name]['data']
            table_data = self.key_value_table.get_data()
            if have_data != table_data:
                self.data[self.selected_name]['data'] = table_data
                self.data_changed.emit()


class Edit(EditCtrl):
    """
    The background widget that sets up how the user can edit the element,
    visible when editing the module.
    """
    def __init__(self, cfg, main, parent_cfg):
        super(Edit, self).__init__(cfg, main, parent_cfg)

    @staticmethod
    def element_name():
        """The elements display name shown in UI"""
        return 'Uniformat_Lister'

    @staticmethod
    def element_icon():
        return a2ctrl.Icons.check


def get_settings(module_key, cfg, db_dict, user_cfg):
    """
    Called by the module on "change" to get an elements data thats
    eventually written into the runtime includes.

    Passed into is all you might need:
    :param str module_key: "module_source_name|module_name" combo used to identify module in db
    :param dict cfg: Standard element configuration dictionary.
    :param dict db_dict: Dictionary that's used to write the include data with "hotkeys", "variables" and "includes" keys
    :param dict user_cfg: This elements user edits saved in the db

    To make changes to the:
    * "variables" - a simple key, value dictionary in db_dict

    Get the current value via get_cfg_value() given the default cfg and user_cfg.
    If value name is found it takes the value from there, otherwise from cfg or given default.

        value = a2ctrl.get_cfg_value(cfg, user_cfg, typ=bool, default=False)

    write the key and value to the "variables" dict:

        db_dict['variables'][cfg['name']] = value

    * "hotkeys" - a dictionary with scope identifiers

    * "includes" - a simple list with ahk script paths
    """
    pass
