import json
import os
from typing import List, Dict

class WorkflowCombiner:
    def __init__(self, base_path: str = "/workflows"):
        self.base_path = base_path
        self.workflows = {}
        self.load_workflows()

    def load_workflows(self):
        """Load all workflow JSON files"""
        for root, _, files in os.walk(self.base_path):
            for file in files:
                if file.endswith('.json'):
                    with open(os.path.join(root, file), 'r') as f:
                        self.workflows[file] = json.load(f)

    def create_story_sequence(self, 
                            scene_types: List[str], 
                            prompts: List[str],
                            audio_files: List[str] = None) -> Dict:
        """Combine multiple workflows into a story sequence"""
        sequence = {
            "name": "Combined Story Sequence",
            "scenes": [],
            "transitions": [],
            "audio_sync": {}
        }

        # Add scenes based on type
        for i, (scene_type, prompt) in enumerate(zip(scene_types, prompts)):
            if "character" in scene_type.lower():
                workflow = self.workflows.get("character_lipsync_advanced.json")
            elif "trailer" in scene_type.lower():
                workflow = self.workflows.get("movie_trailer_advanced.json")
            else:
                workflow = self.workflows.get("story_scene_advanced.json")

            if workflow:
                scene = self._customize_workflow(workflow, prompt)
                sequence["scenes"].append(scene)

        return sequence

    def _customize_workflow(self, workflow: Dict, prompt: str) -> Dict:
        """Customize a workflow with specific prompt"""
        custom = workflow.copy()
        # Customize nodes and settings based on prompt
        return custom

if __name__ == "__main__":
    combiner = WorkflowCombiner()
    sequence = combiner.create_story_sequence(
        scene_types=["character", "scene", "trailer"],
        prompts=[
            "narrator explaining the concept",
            "showing the alternative world",
            "dramatic finale sequence"
        ]
    )
    print(json.dumps(sequence, indent=2)) 