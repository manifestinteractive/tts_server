import os.path
import tempfile
import unittest
from pathlib import Path

from config import AlltalkConfig, AlltalkTTSEnginesConfig, AlltalkNewEnginesConfig


class TestAlltalkConfig(unittest.TestCase):

    def setUp(self):
        self.config = AlltalkConfig.get_instance()
        self.config.reload()

    def test_default_config_path(self):
        expected_config_path = Path(__file__).parent.parent.resolve() / "confignew.json"
        self.assertEqual(self.config.get_config_path(), expected_config_path)
        self.assertEqual(AlltalkConfig.default_config_path(), expected_config_path)

    def test_branding(self):
        self.assertEqual(self.config.branding, "AllTalk ")

    def test_delete_output_wavs(self):
        self.assertEqual(self.config.delete_output_wavs, "Disabled")

    def test_gradio_interface(self):
        self.assertTrue(self.config.gradio_interface)

    def test_output_folder(self):
        self.assertEqual(self.config.output_folder, "outputs")
        # Testing the side effect of creating the output folder:
        output_folder = Path(__file__).parent.parent.resolve() / self.config.output_folder
        self.assertTrue(output_folder.exists())

    def test_gradio_port_number(self):
        self.assertEqual(self.config.gradio_port_number, 7852)

    def test_firstrun_model(self):
        self.assertTrue(self.config.firstrun_model)

    def test_firstrun_splash(self):
        self.assertTrue(self.config.firstrun_splash)

    def test_launch_gradio(self):
        self.assertTrue(self.config.launch_gradio)

    def test_transcode_audio_format(self):
        self.assertEqual(self.config.transcode_audio_format, "Disabled")

    def test_theme(self):
        self.assertEqual(self.config.theme.file, None)
        self.assertEqual(self.config.theme.clazz, "gradio/base")

    def test_rvc_settings(self):
        self.assertFalse(self.config.rvc_settings.rvc_enabled)
        self.assertEqual(self.config.rvc_settings.rvc_char_model_file, "Disabled")
        self.assertEqual(self.config.rvc_settings.rvc_narr_model_file, "Disabled")
        self.assertTrue(self.config.rvc_settings.split_audio)
        self.assertEqual(self.config.rvc_settings.pitch, 0)
        self.assertEqual(self.config.rvc_settings.filter_radius, 3)
        self.assertEqual(self.config.rvc_settings.index_rate, 0.75)
        self.assertEqual(self.config.rvc_settings.rms_mix_rate, 1)
        self.assertEqual(self.config.rvc_settings.protect, 0.5)
        self.assertEqual(self.config.rvc_settings.hop_length, 130)
        self.assertEqual(self.config.rvc_settings.f0method, "fcpe")
        self.assertEqual(self.config.rvc_settings.embedder_model, "hubert")
        self.assertEqual(self.config.rvc_settings.training_data_size, 45000)

    def test_tgwui(self):
        self.assertTrue(self.config.tgwui.tgwui_activate_tts)
        self.assertTrue(self.config.tgwui.tgwui_autoplay_tts)
        self.assertEqual(self.config.tgwui.tgwui_narrator_enabled, "false")
        self.assertEqual(self.config.tgwui.tgwui_non_quoted_text_is, "character")
        self.assertFalse(self.config.tgwui.tgwui_deepspeed_enabled)
        self.assertEqual(self.config.tgwui.tgwui_language, "English")
        self.assertFalse(self.config.tgwui.tgwui_lowvram_enabled)
        self.assertEqual(self.config.tgwui.tgwui_pitch_set, 0)
        self.assertEqual(self.config.tgwui.tgwui_temperature_set, 0.75)
        self.assertEqual(self.config.tgwui.tgwui_repetitionpenalty_set, 10)
        self.assertEqual(self.config.tgwui.tgwui_generationspeed_set, 1)
        self.assertEqual(self.config.tgwui.tgwui_narrator_voice, "female_01.wav")
        self.assertTrue(self.config.tgwui.tgwui_show_text)
        self.assertEqual(self.config.tgwui.tgwui_character_voice, "female_01.wav")
        self.assertEqual(self.config.tgwui.tgwui_rvc_char_voice, "Disabled")
        self.assertEqual(self.config.tgwui.tgwui_rvc_narr_voice, "Disabled")

    def test_api_def(self):
        self.assertEqual(self.config.api_def.api_port_number, 7851)
        self.assertIn("a-zA-Z0-9", self.config.api_def.api_allowed_filter)
        self.assertEqual(self.config.api_def.api_length_stripping, 3)
        self.assertEqual(self.config.api_def.api_max_characters, 2000)
        self.assertFalse(self.config.api_def.api_use_legacy_api)
        self.assertEqual(self.config.api_def.api_legacy_ip_address, "127.0.0.1")
        self.assertEqual(self.config.api_def.api_text_filtering, "standard")
        self.assertEqual(self.config.api_def.api_narrator_enabled, "false")
        self.assertEqual(self.config.api_def.api_text_not_inside, "character")
        self.assertEqual(self.config.api_def.api_language, "en")
        self.assertEqual(self.config.api_def.api_output_file_name, "myoutputfile")
        self.assertTrue(self.config.api_def.api_output_file_timestamp)
        self.assertFalse(self.config.api_def.api_autoplay)
        self.assertEqual(self.config.api_def.api_autoplay_volume, 0.5)

    def test_debugging(self):
        self.assertFalse(self.config.debugging.debug_transcode)
        self.assertFalse(self.config.debugging.debug_tts)
        self.assertFalse(self.config.debugging.debug_openai)
        self.assertFalse(self.config.debugging.debug_concat)
        self.assertFalse(self.config.debugging.debug_tts_variables)
        self.assertFalse(self.config.debugging.debug_rvc)

    def test_gradio_pages(self):
        self.assertTrue(self.config.gradio_pages.Generate_Help_page)
        self.assertTrue(self.config.gradio_pages.Voice2RVC_page)
        self.assertTrue(self.config.gradio_pages.TTS_Generator_page)
        self.assertTrue(self.config.gradio_pages.TTS_Engines_Settings_page)
        self.assertTrue(self.config.gradio_pages.alltalk_documentation_page)
        self.assertTrue(self.config.gradio_pages.api_documentation_page)

    def test_save_config(self):
        with tempfile.NamedTemporaryFile(suffix=".json") as tmp:
            self.config.branding = "foo"
            self.config.save(tmp.name)
            new_config = AlltalkConfig(tmp.name)
            self.assertEqual(new_config.branding, "foo")

    def test_no_private_fields(self):
        for attr in self.config.to_dict().keys():
            self.assertTrue(not attr.startswith("_"))

class TestAlltalkTTSEnginesConfig(unittest.TestCase):

    def setUp(self):
        self.tts_engines_config = AlltalkTTSEnginesConfig.get_instance()
        self.tts_engines_config.reload()

    def test_tts_engines(self):
        self.assertEqual(self.tts_engines_config.engine_loaded, "piper")
        self.assertEqual(self.tts_engines_config.selected_model, "piper")
        self.assertListEqual(self.tts_engines_config.get_engine_names_available(), ["parler", "piper", "vits", "xtts", "f5tts"])

    def test_is_valid_engine(self):
        for engine in ["parler", "piper", "vits", "xtts", "f5tts"]:
            self.assertTrue(self.tts_engines_config.is_valid_engine(engine))

        self.assertFalse(self.tts_engines_config.is_valid_engine("foo"))

    def test_change_tts_engine(self):
        self.tts_engines_config.change_engine("vits")
        self.assertEqual(self.tts_engines_config.engine_loaded, "vits")
        self.assertEqual(self.tts_engines_config.selected_model, "vits - tts_models--en--vctk--vits")

    def test_tts_engines_default_config_path(self):
        expected_config_path = os.path.join(Path(__file__).parent.parent.resolve(), "system", "tts_engines", "tts_engines.json")
        self.assertEqual(self.tts_engines_config.get_config_path(), Path(expected_config_path))

    def test_tts_engines_save(self):
        with tempfile.NamedTemporaryFile(suffix=".json") as tmp:
            self.tts_engines_config.engine_loaded = "foo"
            self.tts_engines_config.save(tmp.name)
            new_config = AlltalkTTSEnginesConfig(tmp.name)
            self.assertEqual(new_config.engine_loaded, "foo")
            self.assertListEqual(new_config.get_engine_names_available(), ["parler", "piper", "vits", "xtts", "f5tts"])
            self.assertEqual(len(new_config.engines_available), len(new_config.get_engine_names_available()))

    def test_merge_with_new_engines(self):
        with tempfile.NamedTemporaryFile(suffix=".json") as tmp:
            self.tts_engines_config.engines_available = []
            self.assertListEqual(self.tts_engines_config.get_engine_names_available(), [])

            self.tts_engines_config.save(tmp.name)

            new_config = AlltalkTTSEnginesConfig(tmp.name)
            self.assertEqual(new_config.get_engine_names_available(), ["parler", "xtts", "f5tts"])
            self.assertEqual(len(new_config.engines_available), len(new_config.get_engine_names_available()))

    def test_no_private_fields(self):
        for attr in self.tts_engines_config.to_dict().keys():
            self.assertTrue(not attr.startswith("_"))


class TestAlltalkNewEnginesConfig(unittest.TestCase):

    def setUp(self):
        self.new_engines_config = AlltalkNewEnginesConfig.get_instance()
        self.new_engines_config.reload()

    def test_engine_names(self):
        self.assertListEqual(self.new_engines_config.get_engine_names_available(), ["parler", "xtts", "f5tts"])

    def test_get_engine_names_matching(self):
        result = self.new_engines_config.get_engines_matching(lambda x: "tts" in x.name)
        self.assertEqual(len(result), 2)

    def test_no_private_fields(self):
        for attr in self.new_engines_config.to_dict().keys():
            self.assertTrue(not attr.startswith("_"))
