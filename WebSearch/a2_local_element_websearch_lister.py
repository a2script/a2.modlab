from copy import deepcopy

import a2ctrl
import a2element.hotkey
from a2qt import QtWidgets
from a2element import DrawCtrl, EditCtrl
from a2widget import a2item_editor, a2text_field

_DEFAULT_HOTKEY = {
    'enabled': False,
    'key': [''],
    'keyChange': True,
    'multiple': True,
    'scope': [],
    'scopeChange': True,
    'scopeMode': 0,
}


class Draw(DrawCtrl):
    """
    The frontend widget visible to the user with options
    to change the default behavior of the element.
    """

    def __init__(self, *args):
        super(Draw, self).__init__(*args)
        self.main_layout = QtWidgets.QVBoxLayout(self)
        self.main_layout.setContentsMargins(0, 0, 0, 0)

        self.editor = a2item_editor.A2ItemEditor(self)
        # self.editor.ignore_default_values = False
        self.editor.set_data(self.user_cfg)
        self.editor.data_changed.connect(self.delayed_check)
        self.main_layout.addWidget(self.editor)
        self.is_expandable_widget = True

        url = a2text_field.A2CodeField(self)
        self.editor.add_data_label_widget('url', url, url.setText, url.editing_finished, '', 'URL')
        self.editor.add_row('(Use ### as placeholder for selected text)')

        hotkey_cfg_copy = deepcopy(_DEFAULT_HOTKEY)
        self.hotkey = a2element.hotkey.Draw(self, hotkey_cfg_copy)
        self.editor.add_row(self.hotkey)
        self.editor.connect_data_widget(
            'hotkey', self.hotkey, self.hotkey.set_config, self.hotkey.changed, hotkey_cfg_copy
        )

    def check(self):
        self.user_cfg.update(self.editor.data)
        self.set_user_value(self.user_cfg)
        self.change()


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
        return 'Websearch_Lister'

    @staticmethod
    def element_icon():
        return a2ctrl.Icons.check


def get_settings(module_key, cfg, db_dict, user_cfg):
    if not user_cfg:
        return
    db_dict['variables']['websearch_data'] = user_cfg
    for name, data in user_cfg.items():
        hotkey = data.get('hotkey')
        if hotkey is None or not hotkey.get('enabled', False):
            continue

        hk_cfg = deepcopy(_DEFAULT_HOTKEY)
        hk_cfg[a2element.hotkey.Vars.function_code] = f'websearch_handler("{name}")'
        a2element.hotkey.get_settings(module_key, hk_cfg, db_dict, data.get('hotkey'))
