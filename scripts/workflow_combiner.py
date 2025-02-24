import json
import os
from typing import List, Dict, Optional
from dataclasses import dataclass
import logging

@dataclass
class SceneConfig:
    scene_type: str
    prompt: str
    duration: float
    audio_file: Optional[str] = None
    transition_type: Optional[str] = None
    model_quality: str = "base"  # "base" or "advanced"

class WorkflowCombiner:
    def __init__(self, base_path: str = "/workflows"):
        self.base_path = base_path
        self.workflows = {}
        self.transitions = {
            "fade": self._create_fade_transition,
            "zoom": self._create_zoom_transition,
            "dissolve": self._create_dissolve_transition
        }
        self.load_workflows()
        self.setup_logging()

    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)

    def load_workflows(self):
        """Load all workflow JSON files"""
        for root, _, files in os.walk(self.base_path):
            for file in files:
                if file.endswith('.json'):
                    category = os.path.basename(root)
                    with open(os.path.join(root, file), 'r') as f:
                        self.workflows[f"{category}/{file}"] = json.load(f)

    def create_story_sequence(self, scenes: List[SceneConfig]) -> Dict:
        """Create a complete story sequence with transitions and audio"""
        sequence = {
            "name": "Combined Story Sequence",
            "scenes": [],
            "transitions": [],
            "audio_sync": {},
            "metadata": {
                "total_duration": sum(scene.duration for scene in scenes),
                "required_models": set(),
                "vram_requirement": 0
            }
        }

        for i, scene in enumerate(scenes):
            # Load appropriate workflow
            workflow_type = f"{scene.model_quality}_{scene.scene_type}"
            workflow = self._get_workflow(workflow_type)
            
            if not workflow:
                self.logger.warning(f"Workflow not found for type: {workflow_type}")
                continue

            # Customize workflow for scene
            customized_scene = self._customize_workflow(workflow, scene)
            sequence["scenes"].append(customized_scene)

            # Add transition if not last scene
            if i < len(scenes) - 1 and scene.transition_type:
                transition = self._create_transition(
                    scene.transition_type,
                    sequence["scenes"][-1],
                    scenes[i + 1]
                )
                sequence["transitions"].append(transition)

            # Update metadata
            sequence["metadata"]["required_models"].update(
                workflow["metadata"]["required_models"]
            )
            sequence["metadata"]["vram_requirement"] = max(
                sequence["metadata"]["vram_requirement"],
                int(workflow["metadata"]["recommended_vram"].replace("GB", ""))
            )

        return sequence

    def _get_workflow(self, workflow_type: str) -> Optional[Dict]:
        """Get appropriate workflow based on type and quality"""
        type_mapping = {
            "base_character": "character/character_lipsync_base.json",
            "advanced_character": "character/character_lipsync_advanced.json",
            "base_scene": "scene/story_scene_base.json",
            "advanced_scene": "scene/story_scene_advanced.json",
            "base_trailer": "scene/movie_trailer_base.json",
            "advanced_trailer": "scene/movie_trailer_advanced.json"
        }
        return self.workflows.get(type_mapping.get(workflow_type))

    def _customize_workflow(self, workflow: Dict, scene: SceneConfig) -> Dict:
        """Customize workflow with scene-specific settings"""
        custom = workflow.copy()
        
        # Update prompt in relevant nodes
        for node in custom["nodes"].values():
            if node["class_type"] == "CLIPTextEncode":
                node["inputs"]["text"] = scene.prompt

        # Adjust batch size based on duration
        for node in custom["nodes"].values():
            if node["class_type"] == "EmptyLatentImage":
                node["inputs"]["batch_size"] = int(scene.duration * 24)  # 24fps

        return custom

    def _create_transition(self, transition_type: str, scene1: Dict, scene2: Dict) -> Dict:
        """Create transition between scenes"""
        if transition_type in self.transitions:
            return self.transitions[transition_type](scene1, scene2)
        return self._create_fade_transition(scene1, scene2)

    def _create_fade_transition(self, scene1: Dict, scene2: Dict) -> Dict:
        return {
            "type": "fade",
            "duration": 1.0,
            "from_scene": scene1["name"],
            "to_scene": scene2["name"]
        }

    def _create_zoom_transition(self, scene1: Dict, scene2: Dict) -> Dict:
        return {
            "type": "zoom",
            "duration": 1.5,
            "from_scene": scene1["name"],
            "to_scene": scene2["name"],
            "zoom_params": {
                "start_scale": 1.0,
                "end_scale": 1.5,
                "ease": "cubic-in-out"
            }
        }

    def _create_dissolve_transition(self, scene1: Dict, scene2: Dict) -> Dict:
        return {
            "type": "dissolve",
            "duration": 1.0,
            "from_scene": scene1["name"],
            "to_scene": scene2["name"],
            "blend_mode": "normal"
        }

if __name__ == "__main__":
    # Example usage
    combiner = WorkflowCombiner()
    
    scenes = [
        SceneConfig(
            scene_type="character",
            prompt="narrator explaining the concept of ancient Rome with modern tech",
            duration=5.0,
            audio_file="narration.wav",
            model_quality="base"
        ),
        SceneConfig(
            scene_type="scene",
            prompt="roman colosseum with holographic displays and flying vehicles",
            duration=8.0,
            transition_type="zoom",
            model_quality="advanced"
        ),
        SceneConfig(
            scene_type="trailer",
            prompt="epic montage of ancient-modern hybrid civilization",
            duration=6.0,
            audio_file="epic_music.wav",
            model_quality="advanced"
        )
    ]
    
    sequence = combiner.create_story_sequence(scenes)
    print(json.dumps(sequence, indent=2)) 